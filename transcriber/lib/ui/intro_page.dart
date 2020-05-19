import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:transcriber/ui/login_page.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "WELCOME",
        description:
            "Bla bla bla bla bla",
        pathImage: "assets/img/croods3.png",
        backgroundColor: Color(0xffECE2B2),
      ),
    );
    slides.add(
      new Slide(
        title: "Seamless Transcription",
        description:
            "Bla bla bla bla bla",
        pathImage: "assets/img/croods.png",
        backgroundColor: Color(0xffF1A74C),
      ),
    );
    slides.add(
      new Slide(
        title: "Connect with multiple devices",
        description:
            "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        pathImage: "assets/img/croods2.png",
        backgroundColor: Color(0xffAE7C6A),
      ),
    );
  }

  void onDonePress() {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
