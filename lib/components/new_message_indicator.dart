
import 'dart:html';

import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';

class NewMessageIndicator extends StatelessWidget {
  /// This will return a blue box if the message is unread and does not belong to the user. 
  /// Otherwise the box will be transparent.

  final Message? message; 

  const NewMessageIndicator({
    super.key,
    required this.message
  });

  /// This will return the correct color of the widget based on the message.
  /// A message that is unread (isRead == false) and does not belong to the user will return a blue color.
  /// Anything else will be false.
  Color getColor() {

    if(message == null){
      return Colors.transparent;
    }
    else if(message!.isMine){
      return Colors.transparent;
    }
    else if(message!.isRead == true){
      return Colors.transparent;
    }

    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0, 
      height: 10.0, 
      decoration: BoxDecoration(
        color: getColor(),
        shape: BoxShape.circle
      )
    );
  }

}