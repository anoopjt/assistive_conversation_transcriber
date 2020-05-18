import 'package:flutter/material.dart';
import 'package:transcriber/ui/conversation_template.dart';
import 'package:transcriber/ui/login_page.dart';
import 'package:transcriber/widgets/conversations.dart';
import 'package:transcriber/widgets/groups.dart';
//import 'package:transcriber/widgets/category_selector.dart';
import 'package:transcriber/widgets/favorite_contacts.dart';
import 'package:transcriber/ui/border_template.dart';
import 'package:transcriber/networking/sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                title: Text("Join Session"),
                leading: Icon(Icons.add_to_home_screen),
                onTap: () => {}),
            ListTile(
                title: Text("Add favourites"),
                leading: Icon(Icons.group_add),
                onTap: () => {}),
            Divider(),
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
                onTap: () => {}),
            Divider(),
            ListTile(
                title: Text("Sign out"),
                leading: Icon(Icons.exit_to_app),
                onTap: () => {
                      signOutFacebook(),
                      //signOutGoogle(),
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
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 45,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConversationTemplate(),
              ),
            );
          }),
      body: Column(
        children: <Widget>[
          FavoriteContacts(),
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
                  Conversations(), //passing the widget
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}