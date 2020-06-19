import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transcriber/ui/conversation_template.dart';
import 'package:transcriber/ui/login_page.dart';
import 'package:transcriber/networking/sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:transcriber/ui/conversation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

var convos = [];
var formatter = new DateFormat.yMd().add_jm();

String date(timestamp) {
  var _date =
      new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
  return formatter.format(_date);
}

class _HomePageState extends State<HomePage> {
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

  void fetchPrefs() async {
    // TODO: implement initState
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    email = prefs.getString('email');
    imageUrl = prefs.getString('imageUrl');
  }

  @override
  void initState() {
    super.initState();
    fetchPrefs();
    getConvos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Image.asset(
          'assets/img/title.png',
          fit: BoxFit.cover,
          height: 135,
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(name ?? "Name not present"),
              accountEmail: Text(email ?? "Email not present"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrl ?? "",
                ),
                radius: 60,
                backgroundColor: Colors.transparent,
              ),
            ),
            ListTile(
                title: Text("Profile"),
                leading: Icon(Icons.verified_user),
                onTap: () => {}),
            ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
                onTap: () => {}),
            ListTile(
              title: Text("About"),
              leading: Icon(Icons.info),
              onTap: () => {
                showAboutDialog(
                  context: context,
                  applicationIcon: FlutterLogo(),
                  applicationName: 'Transcriber App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '©2020 Transcriber',
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                            'Transcriber is an app set to help hearing imparired, providing real-time speech-to-text transcriptions.'))
                  ],
                )
              },
            ),
            Divider(),
            ListTile(
                title: Text("Sign out"),
                leading: Icon(Icons.exit_to_app),
                onTap: () => {
                      signOutFacebook(),
                      signOutGoogle(),
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }), ModalRoute.withName('/')),
                    }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 5,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConversationTemplate(onSaveCallBack: () async {
                  await new Future.delayed(const Duration(seconds: 3));
                  getConvos();
                }),
              ),
            );
          }),
      body: Column(
        children: <Widget>[
          // FavoriteContacts(),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  conversations(), //passing the widget
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget conversations() {
    return (Expanded(
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
                        builder: (context) =>
                            Conversation(id: convos[index]["id"]),
                      ),
                    );
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
    ));
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
