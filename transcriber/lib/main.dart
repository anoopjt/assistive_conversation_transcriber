import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:transcriber/networking/sign_in.dart';
import 'package:transcriber/ui/home_page.dart';
import 'package:transcriber/ui/intro_page.dart';
import 'package:transcriber/ui/login_page.dart';

void main() {
  // Dart client
  IO.Socket socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
    'transports': ['websocket']
  });
  socket.on('connect', (_) {
    print('connect');
    socket.emit('msg', 'test');
  });
  socket.on('event', (data) => print(data));
  socket.on('disconnect', (_) => print('disconnect'));
  socket.on('fromServer', (_) => print(_));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Transcribe',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Color(0xFFb20a2c),
        accentColor: Color(0xFFFEF9EB),
        primarySwatch: Colors.orange,
      ),
      home: new Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new LoginPage()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _loggedIn = (prefs.getBool('logged') ?? false);

    if (_loggedIn) {
      checkLoginFB().then((value) => {
            print("hiiiii"),
            if (value == "error")
              {
                print("nooooo"),
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                    builder: (context) => new LoginPage(),
                  ),
                ),
              }
            else if (value == "loggedIn")
              {
                print("hiiiii"),
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                    builder: (context) => new HomePage(),
                  ),
                ),
              }
          });
    } else {
      print("sdnfks");
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (context) => new LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    new Timer(new Duration(seconds: 10), () {
      checkLogin();
      checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Loading...'),
      ),
    );
  }
}
