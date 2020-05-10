import 'package:flutter/material.dart';
import 'package:transcriber/ui/group_conversation.dart';

class GroupChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: FlatButton(
          child: Text(
            "New Group",
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupConversation(),
              ),
            );
          },
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
