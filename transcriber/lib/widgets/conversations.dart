import 'package:flutter/material.dart';

void main() => runApp(Conversations());

class Conversations extends StatefulWidget {
  createState() => ConversationsState();
}

final convos = List<String>.generate(20, (i) => "Conversation ${i + 1}");

class ConversationsState extends State<Conversations> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: ListView.builder(
          padding: EdgeInsets.only(top: 10, left: 15, right: 15),
          itemCount: convos.length,
          itemBuilder: (context, index) {
            return Dismissible(
              background: stackBehindDismiss(),
              key: ObjectKey(convos[index]),
              child: Card(
                elevation: 3,
                child: ListTile(
                  title: Text(convos[index]),
                  onTap: () {},
                ),
              ),
              onDismissed: (direction) {
                var item = convos.elementAt(index);
                //To delete
                deleteItem(index);
                //To show a snackbar with the UNDO button
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Item deleted"),
                    action: SnackBarAction(
                        label: "UNDO",
                        textColor: Colors.blue,
                        onPressed: () {
                          //To undo deletion
                          undoDeletion(index, item);
                        })));
              },
            );
          },
        ),
      ),
    );
  }

  void deleteItem(index) {
    /*
    By implementing this method, it ensures that upon being dismissed from our widget tree, 
    the item is removed from our list of items and our list is updated, hence
    preventing the "Dismissed widget still in widget tree error" when we reload.
    */
    setState(() {
      convos.removeAt(index);
    });
  }

  void undoDeletion(index, item) {
    /*
    This method accepts the parameters index and item and re-inserts the {item} at
    index {index}
    */
    setState(() {
      convos.insert(index, item);
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
