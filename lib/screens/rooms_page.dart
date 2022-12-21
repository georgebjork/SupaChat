import 'dart:async';

import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/Message.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({ Key? key }) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const RoomsPage());
  }
}

class _RoomsPageState extends State<RoomsPage> {

  //List of available profiles to message
  List<Profile> profiles = [];

  final Map<String, StreamSubscription<Message?>> messageSubscriptions = {};

  final String userId = supabase.auth.currentUser!.id;

  /// List of rooms
  List<Room> rooms = [];
  StreamSubscription<List<Map<String, dynamic>>>? rawRoomsSubscription;
  bool haveCalledGetRooms = false;

  

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadProfiles () async {
    final List<dynamic> data = await supabase.from('profiles').select();
    profiles = data.map((index) => Profile.fromMap(index)).toList();
  }

  Future<void> initRooms() async {
    if (haveCalledGetRooms) {
      return;
    }
    haveCalledGetRooms = true;

    //Create a subscrition to grab realtime updates on rooms the user is in.
    final List<dynamic> participantMaps = await supabase.from('room_participants').select().eq('profile_id', userId);
    // rawRoomsSubscription = supabase.from('room_participants').stream(primaryKey: ['room_id', 'profile_id'],).listen((participantMaps) async {
    //   if (participantMaps.isEmpty) {
    //     return;
    //   }
    // });
    //rooms = participantMaps.map(Room.fromRoomParticipants).where((room) => room.otherUserId != userId).toList();
    rooms = participantMaps.map((index) => Room.fromRoomParticipants(index)).toList();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Rooms')),
      body: FutureBuilder(
        future: Future.wait([
          loadProfiles(),
          initRooms(),
        ]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return preloader;
          } 

          return Column(
            children: [
              Expanded(flex: 1, child: StartChatBar(profiles: profiles)),
              Expanded(flex: 9, child: DisplayChats(profiles: profiles, rooms: rooms))
            ],
          );
        },
      )
    );
  }
}

class StartChatBar extends StatelessWidget {
  const StartChatBar({
    Key? key,
    required this.profiles
  }) : super(key: key);

  final List<Profile> profiles;

  Future<String> createRoom(String otherUserId) async {
    final data = await supabase.rpc('create_new_room',
      params: {'other_user_id': otherUserId});
    return data as String;
  }

  @override 
  Widget build(BuildContext context){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: profiles.length,
      itemBuilder: (BuildContext context, int index) {  
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Avatar(profile: profiles[index], onPressed: () => createRoom(profiles[index].id)),
                Text(profiles[index].username,  overflow: TextOverflow.ellipsis, maxLines: 1)
              ],
            ),
          ),
        );
      }
    );
  }
}




class DisplayChats extends StatefulWidget {
  
  const DisplayChats({
    Key? key,
    required this.profiles,
    required this.rooms,
  }) : super(key: key);

  final List<Profile> profiles;
  final List<Room> rooms;

  @override
  State<DisplayChats> createState() => _DisplayChatsState();
}

class _DisplayChatsState extends State<DisplayChats> {

  Profile getProfileName(String id){
    int index = widget.profiles.indexWhere((element) => element.id == id);
    return widget.profiles[index];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.rooms.length,
      itemBuilder: (BuildContext context, int index) {  
        Profile? otherUser = getProfileName(widget.rooms[index].otherUserId);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10,10,10,0),
          child: Card(
            child: ListTile(
              onTap: () => Navigator.of(context).push(ChatPage.route(widget.rooms[index].id)),
              leading: Avatar(profile: otherUser),
              title: Text(otherUser.username),
              subtitle: const Text('This will be the most recent message'),
            )
          ),
        );
      }
    );
  }
}




//  Column(
//         children: const [
//           // ListView.builder(
//           //   itemBuilder: (BuildContext context, int index) {  
//           //     return Center(child: Text('Rooms Page'),);
//           // })
//         ],
//       )