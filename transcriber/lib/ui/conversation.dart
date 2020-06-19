import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transcriber/widgets/messages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'dart:convert';

class Conversation extends StatefulWidget {
  final id;

  Conversation({@required this.id});
  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  List<dynamic> transcripts = [];
  var url = "https://act.fahimalizain.com";
  var name;

  void getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
  }

  void getConvo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _jwt = prefs.getString('jwt');
    var body = json.encode({
      "jwt": _jwt,
    });

    http.Response response = await http.post(
        Uri.encodeFull(url + "/api/conv-messages/" + widget.id),
        body: body,
        headers: {'Content-type': 'application/json'});
    var data = JSON.jsonDecode(response.body)["data"];
    setState(() {
      transcripts = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getName();
    getConvo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }
}
