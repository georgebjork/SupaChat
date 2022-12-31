
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/components/new_message_indicator.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';

import '../models/profile.dart';
import '../models/message.dart';

class DisplayChats extends StatefulWidget {
  
  const DisplayChats({Key? key}) : super(key: key);

  @override
  State<DisplayChats> createState() => _DisplayChatsState();
}

class _DisplayChatsState extends State<DisplayChats> {

  @override
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    Provider.of<RoomPageProvider>(context, listen: false).roomsSubscription?.cancel();
    super.dispose();
  }

  Profile getProfile(String id, List<Profile> profiles){
    int index = profiles.indexWhere((element) => element.id == id);
    return profiles[index];
  }


  @override
  Widget build(BuildContext context) {

    final roomsStream = Provider.of<RoomPageProvider>(context, listen: false).roomsStream;

    return StreamBuilder(
      stream: roomsStream,
      builder: (context, snapshot) {
        // If our snapshot has data, we will render
        if(snapshot.hasData &&  Provider.of<RoomPageProvider>(context, listen: false).rooms.isNotEmpty) {
          return Consumer<RoomPageProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.rooms.length,
                itemBuilder: (context, index) {
                  final room = provider.rooms[index];
                  Profile? otherUser = getProfile(room.otherUserId, provider.profiles);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10,10,10,0),
                    child: Card(
                      child: Dismissible(
                        key: Key(room.id),
                        direction: DismissDirection.none,
                        onDismissed:(direction) async => await provider.deleteRoom(index),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(ChatPage.route(room.id, otherUser)),
                          
                          // This row will be used to display a shape to show if there is a new message 
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: NewMessageIndicator(message: room.lastMessage)),
                              Avatar(profile: otherUser),
                            ],
                          ),
                          // If the name is not null, then we will return the full name. Otherwise just user name 
                          title: Text(otherUser.getName() ?? otherUser.username),
                          subtitle: Text(room.lastMessage == null ? '' : room.lastMessage!.content),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(room.lastMessage == null ? '' : format(room.lastMessage!.createdAt, locale: 'en_short')),
                          ),
                        ),
                      )
                    ),
                  );
                },
              );
            },
          );
        }
        else{
          return const Center(child: Text('Click on an avatar above to start a chat :)'));
        }
      }
    );
  }
}