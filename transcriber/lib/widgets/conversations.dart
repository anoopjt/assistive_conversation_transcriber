import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:transcriber/ui/conversation.dart';

void main() => runApp(Conversations());

class Conversations extends StatefulWidget {
  createState() => ConversationsState();
}

var convos = [];
var formatter = new DateFormat.yMd().add_jm();

String date(timestamp) {
  var _date =
      new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
  return formatter.format(_date);
}

class ConversationsState extends State<Conversations> {
  var url = "https://act.fahimalizain.com";

  void getConvos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _jwt = prefs.getString('jwt');
    var body = json.encode({
      "jwt": _jwt,
    });

    http.Response response = await http.post(
        Uri.encodeFull(url + "/api/conversations"),
        body: body,
        headers: {'Content-type': 'application/json'});
    var data = JSON.jsonDecode(response.body)["data"];
    setState(() {
      convos = data;
    });
    print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConvos();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: ListView.builder(
          padding: EdgeInsets.only(top: 10, left: 15, right: 15),
          itemCount: convos.length,
          itemBuilder: (context, index) {
            return Dismissible(
              background: stackBehindDismiss(),
              key: ObjectKey(convos[index]),
              child: Card(
                elevation: 3,
                child: ListTile(
                  title: Text(
                    date(convos[index]["timestamp"]),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(convos[index]["last_message"]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Conversation(id: convos[index]["id"]),
                      ),
                    ).then((val)=>{getConvos()});
                  },
                ),
              ),
              onDismissed: (direction) {
                var item = convos.elementAt(index);
                //To delete
                deleteItem(index);
                //To show a snackbar with the UNDO button
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Item deleted"),
                    action: SnackBarAction(
                        label: "UNDO",
                        textColor: Colors.blue,
                        onPressed: () {
                          //To undo deletion
                          undoDeletion(index, item);
                        })));
              },
            );
          },
        ),
      ),
    );
  }

  void deleteItem(index) {
    /*
    By implementing this method, it ensures that upon being dismissed from our widget tree, 
    the item is removed from our list of items and our list is updated, hence
    preventing the "Dismissed widget still in widget tree error" when we reload.
    */
    setState(() {
      convos.removeAt(index);
    });
  }

  void undoDeletion(index, item) {
    /*
    This method accepts the parameters index and item and re-inserts the {item} at
    index {index}
    */
    setState(() {
      convos.insert(index, item);
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
