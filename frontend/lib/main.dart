import 'package:flutter/material.dart';
import 'package:frontend/ui/login_page.dart';
import 'package:frontend/routes.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  // Dart client
  IO.Socket socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
    'transports': ['websocket']
  });
  print("abcd");
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
      routes: routes,
    );
  }
}