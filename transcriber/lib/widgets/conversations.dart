import 'package:flutter/material.dart';
import 'package:transcriber/ui/conversation_template.dart';

class Conversations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: FlatButton(
          child: Text(
            "New Conversation",
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConversationTemplate(),
              ),
            );
          },
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
