import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:mic_stream/mic_stream.dart';

class ConversationTemplate extends StatefulWidget {
  ConversationTemplate({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConversationTemplateState createState() => _MyConversationTemplateState();
}

class _MyConversationTemplateState extends State<ConversationTemplate> {
  bool _isRecording = false;
  StreamSubscription<List<int>> listener;

  void _record() {
    if (_isRecording) {
      listener.cancel();
    } else {
      // listener =
      //     microphone(sampleRate: 16000).listen((samples) => print(samples));
    }

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {
              /*...*/
            },
            icon: Icon(Icons.save_alt),
            label: Text("Save"),
            textColor: Colors.white,
          )
        ],
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
          elevation: 2.0,
          tooltip: 'Record',
          child: Icon(_isRecording ? Icons.mic : Icons.mic_off),
          backgroundColor: _isRecording ? Colors.red : Colors.green),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person_add), //`Icon` to display
              label: Text('Add Person'), //`Text` to display
              onPressed: () {
                //Code to execute when Floating Action Button is clicked
                //...
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.language), //`Icon` to display
              label: Text('Language'), //`Text` to display
              onPressed: () {
                //Code to execute when Floating Action Button is clicked
                //...
              },
            ),
          ],
        ),
      ),
    );
  }
}
