import 'dart:async';
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/room_page_provider.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({ Key? key }) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const RoomsPage());
  }
}

class _RoomsPageState extends State<RoomsPage> {

  // FOR LATER USE
  // final Map<String, StreamSubscription<Message?>> messageSubscriptions = {};
  // StreamSubscription<List<Map<String, dynamic>>>? rawRoomsSubscription;

  //List of available profiles to message
  List<Profile> profiles = [];

  // List of rooms you are a part of
  List<Room> rooms = [];

  // The Current User Id
  final String userId = supabase.auth.currentUser!.id;

  // Have we called this initRooms already? If so then we dont have to call again.
  bool haveCalledGetRooms = false;


  @override
  void initState() {
    super.initState();
  }

  // This will load all of the available profiles to message 
  Future<void> loadProfiles () async {
    // Grab all profiles 
    final List<dynamic> data = await supabase.from('profiles').select();
    profiles = data.map((index) => Profile.fromMap(index)).toList();
  }

  // This will load all rooms and set up a stream to listen to updates
  Future<void> loadRooms() async {
    // Check to see if we need to call again 
    if (haveCalledGetRooms) {
      return;
    }
    haveCalledGetRooms = true;

    // Grab all of the rooms we are a part of, but filter out ourselves. Row Line Security will only allow us to query rooms we are in.
    final List<dynamic> currentRooms = await supabase.from('room_participants').select().neq('profile_id', userId);
    rooms = currentRooms.map((index) => Room.fromRoomParticipants(index)).toList();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'), 
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),

      body: FutureBuilder(
        future: Future.wait([
          loadProfiles(),
          loadRooms(),
        ]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return preloader;
          } 

          // Set the provider data
          Provider.of<RoomPageProvider>(context, listen: false).profiles = profiles;
          Provider.of<RoomPageProvider>(context, listen: false).rooms = rooms;

          return Column(
            children: const [
              Expanded(flex: 1, child: StartChatBar()),
              Expanded(flex: 9, child: DisplayChats())
            ],
          );
        },
      )
    );
  }
}

class StartChatBar extends StatelessWidget {
  const StartChatBar({Key? key,}) : super(key: key);

  Future<String> createRoom(String otherUserId) async {
    final data = await supabase.rpc('create_new_room',
      params: {'other_user_id': otherUserId});
    return data as String;
  }

  @override 
  Widget build(BuildContext context){

    List<Profile>? profiles = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    List<Room>? rooms = Provider.of<RoomPageProvider>(context, listen: false).rooms;
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: profiles!.length,
      itemBuilder: (BuildContext context, int index) {  
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Avatar(profile: profiles[index], onPressed: () async {
                  // Get a room id from function 
                  String roomId = await createRoom(profiles[index].id);
                  // If it exists already, then navigate to it
                  if(rooms!.map((e) => e.id).contains(roomId)) { Navigator.of(context).push(ChatPage.route(roomId)); }
                }),

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
  
  const DisplayChats({Key? key}) : super(key: key);

  @override
  State<DisplayChats> createState() => _DisplayChatsState();
}

class _DisplayChatsState extends State<DisplayChats> {

  late final Stream<List<Room>> roomsStream;
  final String userId = supabase.auth.currentUser!.id;

  Profile getProfileName(String id, List<Profile> profiles){
    int index = profiles.indexWhere((element) => element.id == id);
    return profiles[index];
  }

  void setRoomsListener() {
    // Create a subscription to get realtime updates on room creation
    roomsStream = supabase
    .from('room_participants')
    .stream(primaryKey: ['room_id', 'profile_id'])
    .neq('profile_id', userId)
    .map((event) => event.map((e) => Room.fromRoomParticipants(e)).toList());
  }

  @override
  void initState() {
    setRoomsListener();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    List<Profile>? profiles = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    List<Room>? roomsOriginal = Provider.of<RoomPageProvider>(context, listen: false).rooms;

    if(roomsOriginal!.isEmpty){
      return const Center(child: Center(child: Text('Click on an Avatar above and send them a message :) ')));
    }

    return StreamBuilder<List<Room>>(
      stream: roomsStream,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          final rooms = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: rooms.length,
            itemBuilder: (BuildContext context, int index) {  
              Profile? otherUser = getProfileName(rooms[index].otherUserId, profiles!);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(ChatPage.route(rooms[index].id)),
                    leading: Avatar(profile: otherUser),
                    title: Text(otherUser.username),
                    subtitle: const Text('This will be the most recent message'),
                  )
                ),
              );
            }
          );
        }
        else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: roomsOriginal.length,
            itemBuilder: (BuildContext context, int index) {  
              Profile? otherUser = getProfileName(roomsOriginal[index].otherUserId, profiles!);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(ChatPage.route(roomsOriginal[index].id)),
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
    );
  }
}