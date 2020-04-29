import 'package:flutter/material.dart';
import 'package:frontend/ui/home_page.dart';
import 'package:frontend/ui//login_page.dart';
import 'package:frontend/ui/chat_page.dart';

final routes = {
  '/login':         (BuildContext context) => new LoginPage(),
  '/home':         (BuildContext context) => new HomeScreen(),
  '/' :          (BuildContext context) => new LoginPage(),
  //'/chat'  : (BuildContext context) => new ChatScreen(),
};