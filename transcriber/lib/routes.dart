import 'package:flutter/material.dart';
import 'package:transcriber/ui/home_page.dart';
import 'package:transcriber/ui//login_page.dart';
import 'package:transcriber/ui/chat_page.dart';
import 'package:transcriber/ui/intro_page.dart';

final routes = {
  '/login':         (BuildContext context) => new LoginPage(),
  '/home':         (BuildContext context) => new HomePage(),
  '/' :          (BuildContext context) => new IntroScreen(),
  //'/chat'  : (BuildContext context) => new ChatScreen(),
};