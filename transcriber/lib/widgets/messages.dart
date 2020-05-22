import 'package:flutter/material.dart';
import 'package:transcriber/models/message_model.dart';
import 'package:transcriber/models/user_model.dart';

class Messages extends StatelessWidget {
  final txt;

  Messages({this.txt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // MyCircleAvatar(
        //   imgUrl: messages[i]['contactImgUrl'],
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Person",
              style: Theme.of(context).textTheme.caption,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Color(0xfff9f9f9),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Text(
                "$txt",
                style: Theme.of(context).textTheme.body1.apply(
                      color: Colors.black87,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(width: 15),
        Text(
          "18:00",
          style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
        ),
      ],
    );
  }
}
