import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:transcriber/ui/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

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

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
    // new Timer(new Duration(milliseconds: 200), () {
    //   checkFirstSeen();
    // });

    slides.add(
      new Slide(
        title: "ERASER",
        description:
            "Allow miles wound place the leave had. To sitting subject no improve studied limited",
        pathImage: "images/photo_eraser.png",
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: "PENCIL",
        description:
            "Ye indulgence unreserved connection alteration appearance",
        pathImage: "images/photo_pencil.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "RULER",
        description:
            "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        pathImage: "images/photo_ruler.png",
        backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  void onDonePress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
