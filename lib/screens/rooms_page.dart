import 'dart:async';
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/Message.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/theme_provider.dart';
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

  //List of available profiles to message
  List<Profile> currentProfileData = [];

  // List of rooms you are a part of
  List<Room> currentRoomData = [];

  // The Current User Id
  final String userId = supabase.auth.currentUser!.id;
  // This is the user profile
  Profile? userProfile;

  @override
  void initState() {
    super.initState();
  }

  // This will load all of the available profiles to message 
  Future<void> loadProfiles () async {
    // Grab all profiles 
    final List<dynamic> data = await supabase.from('profiles').select();
    currentProfileData = data.map((index) => Profile.fromMap(index)).toList();
    
    int index = currentProfileData.indexWhere((element) => element.id == userId);
    userProfile = currentProfileData[index];
    setState(() {});
  }

  // This will load all of the rooms for user from the database
  Future<void> loadRooms() async {
    // Grab all of the rooms we are a part of, but filter out ourselves. Row Line Security will only allow us to query rooms we are in.
    final List<dynamic> currentRooms = await supabase.from('room_participants').select().neq('profile_id', userId);
    currentRoomData = currentRooms.map((index) => Room.fromRoomParticipants(index)).toList();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userProfile: userProfile),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
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
          Provider.of<RoomPageProvider>(context, listen: false).profiles = currentProfileData;
          Provider.of<RoomPageProvider>(context, listen: false).rooms = currentRoomData;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 80, child: StartChatBar()),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Chats', style: TextStyle(fontSize: 25)),
              ),
              Expanded(child: DisplayChats())
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

  // Data I need:

  // A stream of all room data. This will notify us of the addition of rooms.  StreamSubscription<List<Map<String, dynamic>>>? roomsStream;
  // A list of all rooms not attached to the stream subscription. This will allow us to change data. List<Room> rooms
  // A stream of all chat messages data. This will notify us about new chats to display on the room cards. final Map<String, StreamSubscription<Message?>> messagesStream = {};

  int renderCount = 0;
  // Room data
  StreamSubscription<List<Map<String, dynamic>>>? roomsStream;
  List<Room> rooms = [];

  //Message data
  final Map<String, StreamSubscription<Message?>> messagesStream = {};

  // User id
  final String userId = supabase.auth.currentUser!.id;

  List<Room> sortRooms(List<Room> r){
    // This should be moved into its own function. It should be used when rooms are also created. It should also sort and then render
    r.sort((a, b) {
      // Sort according to the last message
      // Use the room createdAt when last message is not available
      final aTimeStamp = a.lastMessage != null ? a.lastMessage!.createdAt : a.createdAt;
      final bTimeStamp = b.lastMessage != null ? b.lastMessage!.createdAt : b.createdAt;
      return bTimeStamp.compareTo(aTimeStamp);
    });

    return r;
  }

  Future<void> setRoomsListener() async {

    roomsStream = supabase.from('room_participants').stream(primaryKey: ['room_id', 'profile_id']).neq('profile_id', userId).listen((listOfRooms) async {
      
      rooms = listOfRooms.map((e) => Room.fromRoomParticipants(e)).toList();
      for (final room in rooms) {
        getNewestMessage(roomId: room.id);
      }
    }); 
  }

  void getNewestMessage({required roomId}) {
    messagesStream['roomId'] = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .limit(1)
        .map<Message?>(
          (data) => data.isEmpty
              ? null
              : Message.fromMap(
                  map: data.first,
                  myUserId: userId,
                ),
        )
        .listen((message) {
          // Set the newest message 
          final index = rooms.indexWhere((room) => room.id == roomId);
          rooms[index] = rooms[index].copyWith(lastMessage: message);

          rooms = sortRooms(rooms);
          setState(() {});
        });
  }

  Profile getProfileName(String id, List<Profile> profiles){
    int index = profiles.indexWhere((element) => element.id == id);
    return profiles[index];
  }

  @override
  void initState() {
    // Get init data
    rooms = Provider.of<RoomPageProvider>(context, listen: false).rooms!;

    // Set the listener
    setRoomsListener();

    super.initState();
  }

  @override
  void dispose(){
    roomsStream?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    List<Profile>? currentProfileData = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    
    if(rooms.isNotEmpty){
      print('Render ${renderCount++} times');
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
                onTap: () => Navigator.of(context).push(ChatPage.route(rooms[index].id)),
                leading: Avatar(profile: otherUser),
                title: Text(otherUser.username),
                subtitle: Text(rooms[index].lastMessage == null ? '' : rooms[index].lastMessage!.content),
              )
            ),
          );
        }
      );
    }

    else{
      return const Center(child: Text('Click on an avatar above to start a chat :)'));
    }
    
     
  }
}


class HomeDrawer extends StatefulWidget {

  final Profile? userProfile;
  
  const HomeDrawer({super.key, required this.userProfile});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final themeData = Provider.of<ThemeProvider>(context, listen: false);
    return Drawer(
      
      child: Column(
        children: [
          DrawerHeader(child: (widget.userProfile == null) ? null : Avatar(profile: widget.userProfile, radius: 50, fontSize: 40)),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(leading: const Icon(Icons.account_circle_outlined), title: const Text('Edit Account'), onTap: () => context.showSnackBar(message: 'Not yet implmented!'))
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              children: [
                const Divider(),
                ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => context.showSnackBar(message: 'Not yet implmented!')),
                SwitchListTile(
                  title: const Text('Light or Dark Mode'),
                  secondary: themeData.isDark ? const Icon(Icons.brightness_2_outlined) : const Icon(Icons.brightness_low_sharp),
                  value: themeData.isDark, 
                  activeColor: themeData.green, 
                  onChanged: (toggled) { 
                    setState(() {
                      if(themeData.isDark == true){
                        themeData.setTheme('light');
                      }
                      else {
                        themeData.setTheme('dark');
                      }
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}