import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/utils/constants.dart';



class ChatPage extends StatefulWidget {
  final String roomId; 
  final Profile otherUser;
  const ChatPage({ Key? key, required this.roomId, required this.otherUser}) : super(key: key);

  static Route<void> route(String id, Profile user) {
    return MaterialPageRoute(builder: (context) => ChatPage(roomId: id, otherUser: user));
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  late final Stream<List<Message>> _messagesStream;

  //Hold the current user
  final userId = supabase.auth.currentUser!.id;

  @override
  void initState() {
    setMessagesListener(widget.roomId);
    setAllMessagesRead();
    super.initState();
  }

  void setMessagesListener(String roomId){

    //Grab chats. The stream will allow us to grab this in real time
    print('Start Message Stream (Chat Page): ${widget.otherUser.username}');
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((maps) => maps.map((map) => Message.fromMap(map: map, myUserId: userId)).toList());
  }


  /// This will set all messages that have not been read as read
  void setAllMessagesRead() async {
    final data = await supabase.rpc('read_message', params: {'room_id' : widget.roomId, 'user_id' : userId});
    print('Message updated: $data');
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.getName() ?? widget.otherUser.username, overflow: TextOverflow.ellipsis, maxLines: 1), 
        iconTheme: Theme.of(context).iconTheme
      ),

      
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('Start your conversation now :)'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ChatBubble(
                              message: message,
                              profile: widget.otherUser,
                            );
                          },
                        ),
                ),
                MessageBar(roomId: widget.roomId),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }

}

