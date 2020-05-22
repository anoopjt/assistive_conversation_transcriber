import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transcriber/networking/sign_in.dart';
import 'package:transcriber/ui/home_page.dart';
import 'package:transcriber/ui/intro_page.dart';
import 'package:transcriber/ui/login_page.dart';
import 'package:flutter/scheduler.dart';

void main() {
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
      checkLogin();
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
            if (value == "error")
              {
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                    builder: (context) => new LoginPage(),
                  ),
                ),
              }
            else if (value == "loggedIn")
              {
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                    builder: (context) => new HomePage(),
                  ),
                ),
              }
          });
    } else {
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
