import 'package:flutter/material.dart';

typedef CustomCallBack = Widget Function();

class BorderTemplate extends StatelessWidget {
  final Widget item;

  BorderTemplate({this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                item, //passing the widget
              ],
            ),
          ),
        ),
      ],
    );
  }
}
