from flask import Flask, session, request
from flask_socketio import SocketIO, emit
from ..transcriber import Transcriber
import threading, random, string

"""
  Details of SocketIO exchanges:
  To start the process, Client sends `transcription_init`
  - We send back `transcription_id`
  
  Client send `transcription_start`
  - We start the transcriber

  Client send `transcribe_data`
  - We transcribe it

  Client sends `transcription_stop`
  - We stop the trancriber

  Client send `transcription_destroy`
  - We clean up, forget tsid
"""

transcriptionSessions = {}

def init_app(app: Flask, session: session, socketio: SocketIO):

  def on_transcription(tsid, is_final, txt):
    print("ON TR", len(transcriptionSessions.keys()))
    if tsid not in transcriptionSessions:
      return
    
    transcripts = transcriptionSessions[tsid]["transcripts"]
    


  @socketio.on("transcription_init")
  def tr_init():
    tsid = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(30))
    sid = request.sid
    
    transcripts = []
    t = Transcriber(sid, tsid)
    transcriptionSessions[tsid] = {
      "tsid": tsid,
      "sid": sid,
      "transcriber": Transcriber(sid, tsid),
    }
    emit("transcription_id", tsid)
  
  @socketio.on("transcription_start")
  def tr_start(tsid):
    if tsid not in transcriptionSessions:
      return
    
    tr: Transcriber = transcriptionSessions[tsid].get("transcriber")
    t = threading.Thread(target=tr.start)
    t.start()
  
  @socketio.on("transcribe_data")
  def tr_data(tsid, data):
    if tsid not in transcriptionSessions:
      return
    
    tr: Transcriber = transcriptionSessions[tsid].get("transcriber")
    emit("transcripts", tr.transcripts)
    tr.fill_data(data)
  
  @socketio.on("transcription_stop")
  def tr_stop(tsid):
    if tsid not in transcriptionSessions:
      return
    
    tr: Transcriber = transcriptionSessions[tsid].get("transcriber")
    print(transcriptionSessions[tsid].get("transcripts"))
    tr.stop()
  
  @socketio.on("transcription_destroy")
  def tr_destroy(tsid):
    if tsid not in transcriptionSessions:
      return
    
    tr: Transcriber = transcriptionSessions[tsid].get("transcriber")
    tr.stop()
    transcriptionSessions[tsid] = None