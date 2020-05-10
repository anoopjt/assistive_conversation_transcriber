import 'package:flutter/material.dart';
//import 'package:transcriber/widgets/category_selector.dart';
//import 'package:transcriber/widgets/favorite_contacts.dart';
import 'package:transcriber/widgets/recent_chats.dart';
import 'package:transcriber/widgets/notes.dart';
import 'package:transcriber/widgets/group_chats.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transcriber/ui/border_template.dart';

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
            appBar: AppBar(
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
                labelStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'WorkSans'),
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
                  item: GroupChat(),
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
