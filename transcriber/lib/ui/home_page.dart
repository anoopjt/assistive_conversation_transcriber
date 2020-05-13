import 'package:flutter/material.dart';
import 'package:transcriber/ui/login_page.dart';
import 'package:transcriber/widgets/conversations.dart';
//import 'package:transcriber/widgets/category_selector.dart';
//import 'package:transcriber/widgets/favorite_contacts.dart';
import 'package:transcriber/widgets/recent_chats.dart';
import 'package:transcriber/widgets/notes.dart';
import 'package:transcriber/widgets/conversations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transcriber/ui/border_template.dart';
import 'package:transcriber/networking/sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: new ThemeData(
          primaryColor: Color(0xFFb20a2c),
          accentColor: Color(0xFFFEF9EB),
          primarySwatch: Colors.orange,
        ),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
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
              bottom: TabBar(
                labelStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'WorkSans'),
                tabs: <Widget>[
                  Tab(
                    text: "Messages",
                  ),
                  Tab(
                    text: "Conversations",
                  ),
                  Tab(
                    text: "Notes",
                  ),
                ],
              ),
            ),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(name ?? "Name not present"),
                    accountEmail: Text(email ?? "Email not present" ),
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
                      onTap: () => {}),
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
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 45,
                ),
                onPressed: () {
                  switch (DefaultTabController.of(context).index) {
                    case 1:
                      {
                        print('1');
                      }
                      break;

                    case 2:
                      {
                        //statements;
                      }
                      break;

                    default:
                      {
                        //statements;
                      }
                      break;
                  }
                }),
            body: TabBarView(
              children: <Widget>[
                BorderTemplate(
                  item: RecentChats(),
                ),
                BorderTemplate(
                  item: Conversations(),
                ),
                BorderTemplate(
                  item: Notes(),
                ),
              ],
            ),
          ),
        ));
  }
}
