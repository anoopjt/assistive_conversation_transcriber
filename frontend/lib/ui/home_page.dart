import 'package:flutter/material.dart';
//import 'package:frontend/widgets/category_selector.dart';
//import 'package:frontend/widgets/favorite_contacts.dart';
import 'package:frontend/widgets/recent_chats.dart';
import 'package:frontend/widgets/notes.dart';
import 'package:frontend/widgets/group_chats.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        appBar: GradientAppBar(
          gradient: LinearGradient(colors: [Color(0xFFb20a2c), Color(0xFFfffbd5)]),
          leading: IconButton(
            icon: Icon(Icons.menu),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
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
            tabs: <Widget>[
              Tab(
                text: "Messages",
              ),
              Tab(
                text: "Groups",
              ),
              Tab(
                text: "Notes",
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          //FAB
          padding: EdgeInsets.all(10),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(.26),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: SvgPicture.asset("assets/icons/plus.svg"),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        //FavoriteContacts(),
                        RecentChats(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              //Groups
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        GroupChat(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              //Notes
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Notes(),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
