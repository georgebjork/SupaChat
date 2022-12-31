import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/utils/constants.dart';

class MessageBar extends StatefulWidget {
  final String roomId;
  const MessageBar({
    Key? key,
    required this.roomId
  }) : super(key: key);

  @override
  State<MessageBar> createState() => MessageBarState();
}

class MessageBarState extends State<MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border:  OutlineInputBorder(borderSide: BorderSide(color: HexColor("#a6a6a6"))),
                    focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: HexColor("#a6a6a6"))),
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) => sendMessage(),
                ),
              ),
              TextButton(
                onPressed: () => sendMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    //Add message to present to the user right away
    final message = Message(
      id: 'new',
      roomId: widget.roomId,
      profileId: myUserId,
      content: text,
      createdAt: DateTime.now(),
      isMine: true,
      isRead: false
    );
    

    try {
      await supabase.from('messages').insert(message.toMap());
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}