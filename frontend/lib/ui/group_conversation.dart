import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';

class GroupConversation extends StatefulWidget {
  GroupConversation({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyGroupConversationState createState() => _MyGroupConversationState();
}

class _MyGroupConversationState extends State<GroupConversation> {
  bool _isRecording = false;
  StreamSubscription<List<int>> listener;

  void _record() {
    if (_isRecording) {
      listener.cancel();
    } else {
      listener =
          microphone(sampleRate: 16000).listen((samples) => print(samples));
    }

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voicey'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Push button and speak something',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _record,
          tooltip: 'Record',
          child: Icon(_isRecording ? Icons.mic : Icons.mic_off),
          backgroundColor: _isRecording ? Colors.red : Colors.green),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat,
    );
  }
}
