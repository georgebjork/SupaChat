
import 'dart:async';

import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/Message.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';

import '../models/profile.dart';
import '../utils/constants.dart';

class DisplayChats extends StatefulWidget {
  
  const DisplayChats({Key? key}) : super(key: key);

  @override
  State<DisplayChats> createState() => _DisplayChatsState();
}

class _DisplayChatsState extends State<DisplayChats> {

  static int renderCount = 0;

  @override
  void initState() {
    
    // Set the listener from the provider
    Provider.of<RoomPageProvider>(context, listen: false).setRoomsListener();
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
        if(snapshot.hasData) {
          return Consumer<RoomPageProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.rooms.length,
                itemBuilder: (context, index) {
                  Profile? otherUser = getProfile(provider.rooms[index].otherUserId, provider.profiles);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10,10,10,0),
                    child: Card(
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(ChatPage.route(provider.rooms[index].id, otherUser)),
                        leading: Avatar(profile: otherUser),
                        // If the name is not null, then we will return the full name. Otherwise just user name 
                        title: Text(otherUser.getName() ?? otherUser.username),
                        subtitle: Text(provider.rooms[index].lastMessage == null ? '' : provider.rooms[index].lastMessage!.content),
                        trailing: Text(provider.rooms[index].lastMessage == null ? '' : format(provider.rooms[index].lastMessage!.createdAt, locale: 'en_short')),
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


/*

return StreamBuilder(
      stream: roomsStream,
      builder: (context, snapshot) {
        if(rooms.isNotEmpty){
          rooms = sortRooms(rooms);
          print('ListView rendered ${++renderCount} times');
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: rooms.length,
            itemBuilder: (BuildContext context, int index) {  
              Profile? otherUser = getProfileName(rooms[index].otherUserId, currentProfileData!);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(ChatPage.route(rooms[index].id, otherUser)),
                    leading: Avatar(profile: otherUser),
                    // If the name is not null, then we will return the full name. Otherwise just user name 
                    title: Text(otherUser.getName() ?? otherUser.username),
                    subtitle: Text(rooms[index].lastMessage == null ? '' : rooms[index].lastMessage!.content),
                  )
                ),
              );
            }
          );
        }
        else {
          return const Center(child: Text('Click on an avatar above to start a chat :)'));
        }
      },
    );





*/