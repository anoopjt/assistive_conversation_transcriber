import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:transcriber/networking/sign_in.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:transcriber/widgets/messages.dart';

final AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

class ConversationTemplate extends StatefulWidget {
  ConversationTemplate({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConversationTemplateState createState() => _MyConversationTemplateState();
}

class _MyConversationTemplateState extends State<ConversationTemplate> {
  bool isRecording = false;
  Stream<List<int>> stream;
  StreamSubscription<List<int>> listener;
  IO.Socket socket;
  String transcriptionId;
  List<dynamic> transcripts = [];

  void _showDialog() {
    slideDialog.showSlideDialog(
      context: context,
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text("Scan QR to join Conversation"),
              QrImage(
                data: jsonEncode({"type": "join", "tsid": transcriptionId}),
                version: QrVersions.auto,
                size: 200,
              ),
              Text('Transcription ID $transcriptionId'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    socket = IO.io('https://act.fahimalizain.com', <String, dynamic>{
      'transports': ['websocket']
    });

    // hard coding my local IP for now
    socket.on('connect', (_) {
      print('SocketIO: Connected!');
      socket.send(["SocketIO: Connected!"]);
      if (this.mounted) {
        setState(() {});
      }
    });
    socket.on("reconnect_attempt", (data) => print("Reconnect Attempt $data"));
    socket.on("reconnect_failed", (data) => print("Reconnect fail $data"));
    socket.on("reconnect_error", (data) => print("Reconnect err $data"));

    socket.on('event', (data) => print(data));
    socket.on('transcripts', (d) {
      if (this.mounted) {
        setState(() {
          transcripts = d;
        });
      }
    });
    socket.on('disconnect', (_) {
      print("Disconnected");
      if (this.mounted) {
        setState(() {});
      }
      if (isRecording) {
        _stopListening();
      }
    });
    socket.on('fromServer', (_) => print(_));
    socket.on("transcription_id", (tid) {
      if (this.mounted) {
        setState(() {
          transcriptionId = tid;
        });
      }
      print("Received Transcription ID $tid");
    });

    super.initState();
    initTranscription();
  }

  void initTranscription() {
    socket.emit("transcription_init", name);
  }

  void startTranscription() {
    if (transcriptionId == null) {
      print("Transcription ID is null");
      return;
    }
    socket.emit("transcription_start", transcriptionId);
  }

  void stopTranscription() {
    if (transcriptionId == null) {
      print("Transcription ID is null");
      return;
    }
    socket.emit("transcription_stop", transcriptionId);
  }

  void abortTranscription() {
    if (transcriptionId == null) {
      print("Transcription ID is null");
      return;
    }
    socket.emit("transcription_destroy", transcriptionId);
    if (this.mounted) {
      setState(() {
        transcriptionId = null;
      });
    }
  }

  void joinTranscription(tsid) {
    socket.emit("transcription_join", [tsid, name]);
    if (this.mounted) {
      setState(() {
        transcriptionId = tsid;
      });
    }
  }

  void scanTranscription() async {
    var result = await BarcodeScanner.scan();
    if (result.type == ResultType.Cancelled) {
      initTranscription();
      return;
    }
    print(result);
    var r = jsonDecode(result.rawContent);
    if (r["type"] == "join") {
      joinTranscription(r["tsid"]);
    }
    print(r);
  }

  int max = 0;
  int min = 0;

  void sendToServer(List<int> sample) {
    if (transcriptionId == null) {
      return;
    }
    bool hasChange = false;
    for (int i in sample) {
      if (i > max) {
        max = i;
        hasChange = true;
      } else if (i < min) {
        min = i;
        hasChange = true;
      }
    }
    if (hasChange) {
      print("Updated MM [$min $max]");
    }
    // var d = Int16List.fromList(sample);
    socket.emit("transcribe_data", [transcriptionId, sample]);
  }

  bool _changeListening() =>
      !isRecording ? _startListening() : _stopListening();

  bool _startListening() {
    if (isRecording) return false;
    stream = microphone(
        audioSource: AudioSource.DEFAULT,
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AUDIO_FORMAT);

    if (this.mounted) {
      setState(() {
        isRecording = true;
      });
    }

    print("Start Listening to the microphone");
    listener = stream.listen((samples) => sendToServer(samples));

    return true;
  }

  bool _stopListening() {
    if (!isRecording) return false;
    print("Stop Listening to the microphone");
    listener.cancel();

    if (this.mounted) {
      setState(() {
        isRecording = false;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = 'English';

    // To show Selected Item in Text.
    String holder = '';

    List<String> languages = [
      'English',
      'Hindi',
      'Malayalam',
      'Tamil',
      'Telugu'
    ];

    void getDropDownItem() {
      setState(() {
        holder = dropdownValue;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {
              abortTranscription();
              scanTranscription();
            },
            icon: Icon(Icons.merge_type),
            label: Text("Join session"),
            textColor: Colors.white,
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(bottom: 30),
                reverse: true,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[]..addAll((transcripts.map(
                      (e) => Messages(
                        txt: e["txt"],
                        full_name: e["full_name"],
                        timestamp: e["timestamp"],
                        username: name,
                      ),
                    ))),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _changeListening();
            if (isRecording) {
              startTranscription();
            } else {
              stopTranscription();
            }
          },
          elevation: 5.0,
          tooltip: 'Record',
          child: Icon(isRecording ? Icons.mic : Icons.mic_off),
          backgroundColor: isRecording ? Colors.red : Colors.green),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 7.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.group_add),
              label: Text('Add a person'),
              onPressed: () {
                _showDialog();
              },
            ),
            SizedBox(width: 15),
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black, fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String data) {
                setState(() {
                  dropdownValue = data;
                });
              },
              items: languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
