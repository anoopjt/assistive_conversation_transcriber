import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  final txt;
  final full_name, username;
  final timestamp;
  var date;

  Messages({this.txt, this.full_name, this.timestamp, this.username}) {
    //date = new DateTime.fromMicrosecondsSinceEpoch(timestamp).toLocal();
  }

  @override
  Widget build(BuildContext context) {
    if (username == full_name) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              "$date",
              style:
                  Theme.of(context).textTheme.body2.apply(color: Colors.grey),
            ),
            SizedBox(width: 15),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
              child: Text(
                "$txt",
                style: Theme.of(context).textTheme.body2.apply(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      );
    } else
      return Row(
        children: [
          // MyCircleAvatar(
          //   imgUrl: messages[i]['contactImgUrl'],
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$full_name",
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
            "$date",
            style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
          ),
        ],
      );
  }
}
