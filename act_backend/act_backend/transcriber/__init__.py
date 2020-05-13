from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types

import sys, re, threading, random, string
from six.moves import queue


class Transcriber(object):

  def __init__(self, sid, tsid):
    self.sid = sid
    self.tsid = tsid
    self.buffer = queue.Queue()
    self.transcripts = []

    self.samplingRate = 16000
    self.language_code = "en-US"

    # GAPI
    self.speechClient = speech.SpeechClient()
    self.config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=self.samplingRate,
        language_code=self.language_code)
    self.streaming_config = types.StreamingRecognitionConfig(
        config=self.config,
        interim_results=True)

  def fill_data(self, data):
    """
    Send fill_data(None) to stop generator
    """
    if isinstance(data, list):
      border = sys.byteorder
      for x in data:
        # 16bits -- 2 bytes
        self.buffer.put(x.to_bytes(2, byteorder=border, signed=True))
    else:
      # None stops the transcription
      self.buffer.put(None)

  def start(self):
    print("Starting tr on thread: ", threading.currentThread().ident)
    import time
    while self.buffer.empty():
      time.sleep(0.5)
    print("Size of Q on TR Thread: ", self.buffer.qsize(), id(self.buffer))
    audio_generator = self.generator()
    requests = (types.StreamingRecognizeRequest(audio_content=content)
                for content in audio_generator)
    responses = self.speechClient.streaming_recognize(self.streaming_config, requests)
    self.process_gapi_response(responses)

    print("Done Transcribing")
  
  def handleTranscript(self, is_final, txt):
    last_tr = None
    if len(self.transcripts):
      last_tr = self.transcripts[-1]
    
    if last_tr and not last_tr["is_final"]:
      last_tr["is_final"] = is_final
      last_tr["txt"] = txt
    else:
      self.transcripts.append({
        "is_final": is_final,
        "txt": txt,
        "tid": ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(50))
      })

  def process_gapi_response(self, responses):
    num_chars_printed = 0
    for response in responses:
      if not response.results:
          continue

      # The `results` list is consecutive. For streaming, we only care about
      # the first result being considered, since once it's `is_final`, it
      # moves on to considering the next utterance.
      result = response.results[0]
      if not result.alternatives:
          continue

      # Display the transcription of the top alternative.
      transcript = result.alternatives[0].transcript

      # Display interim results, but with a carriage return at the end of the
      # line, so subsequent lines will overwrite them.
      #
      # If the previous result was longer than this one, we need to print
      # some extra spaces to overwrite the previous result
      overwrite_chars = ' ' * (num_chars_printed - len(transcript))

      self.handleTranscript(result.is_final, transcript)

      if not result.is_final:
          sys.stdout.write(transcript + overwrite_chars + '\r')
          sys.stdout.flush()

          num_chars_printed = len(transcript)

      else:
          print(transcript + overwrite_chars)

          # Exit recognition if any of the transcribed phrases could be
          # one of our keywords.
          if re.search(r'\b(exit|quit)\b', transcript, re.I):
              print('Exiting..')
              break

          num_chars_printed = 0

  def stop(self):
    self.fill_data(None)

  def generator(self):
    while True:
      chunk = self.buffer.get()
      if chunk is None:
        print("Breaking GENERATOR")
        return
      data = [chunk]

      # Now consume whatever other data's still buffered.
      while True:
        try:
          chunk = self.buffer.get(block=False)
          if chunk is None:
            print("Breaking GENERATOR")
            return
          data.append(chunk)
        except queue.Empty:
          break

      yield b''.join(data)
