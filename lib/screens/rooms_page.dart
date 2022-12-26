import 'dart:async';
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/Message.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/theme_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/profile_page.dart';
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

  int requestProfilesCount = 0;
  int requestCurrentRooms = 0;

  // This will ensure these functions dont get called too many times
  bool hasLoadProfilesCalled = false;
  bool hasLoadRoomsCalled = false;

  @override
  void initState() {
    super.initState();
  }

  // This will load all of the available profiles to message 
  Future<void> loadProfiles () async {
    if(hasLoadProfilesCalled){
      return;
    }

    hasLoadProfilesCalled = true;
    // Grab all profiles 
    print('Request Profiles: ${++requestProfilesCount}');
    final List<dynamic> data = await supabase.from('profiles').select();
    currentProfileData = data.map((index) => Profile.fromMap(index)).toList();
    
    int index = currentProfileData.indexWhere((element) => element.id == userId);
    userProfile = currentProfileData[index];

    // Remove user from the profiles since it will not be needed
    currentProfileData.removeAt(index);
  }

  // This will load all of the rooms for user from the database
  Future<void> loadRooms() async {
    if(hasLoadRoomsCalled){
      return;
    }

    hasLoadRoomsCalled = true;

    print('Request CurrentRooms: ${++requestCurrentRooms}');
    // Grab all of the rooms we are a part of, but filter out ourselves. Row Line Security will only allow us to query rooms we are in.
    final List<dynamic> currentRooms = await supabase.from('room_participants').select().neq('profile_id', userId);
    currentRoomData = currentRooms.map((index) => Room.fromRoomParticipants(index)).toList();

    setState(() {});
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

          else{
            // Set the provider data
            Provider.of<RoomPageProvider>(context, listen: false).profiles = currentProfileData;
            Provider.of<RoomPageProvider>(context, listen: false).rooms = currentRoomData;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [

                // Display avatars
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Avatars', style: TextStyle(fontSize: 25)),
                ),
                SizedBox(height: 80, child: StartChatBar()),
                
                //Display chats
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Chats', style: TextStyle(fontSize: 25)),
                ),
                Expanded(child: DisplayChats())

              ],
            );
          }
        }
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
                  if(rooms!.map((e) => e.id).contains(roomId)) { Navigator.of(context).push(ChatPage.route(roomId, profiles[index])); }
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
  StreamSubscription<List<Room>>? roomsSubscription; 
  Stream<List<Room>>? roomsStream; 
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
    // Listen to the stream and map it into a list of rooms
    roomsStream = supabase.from('room_participants').stream(primaryKey: ['room_id', 'profile_id']).neq('profile_id', userId)
      .map((listOfRooms) => rooms = listOfRooms.map((e) => Room.fromRoomParticipants(e)).toList());
    
    // Now we want to listen to the stream with a subscription. If we hear a change, we want to do something. In this case, set a listener for new messages
    roomsSubscription = roomsStream?.listen(
      // Get the newest data
      (listOfRooms) async {
        for (final room in rooms) {
          getNewestMessage(roomId: room.id);
        }
      },
      onError: (err) => context.showErrorSnackBar(message: err.toString()),
      onDone: () => print('Done!')
    ); 
  }

  void getNewestMessage({required roomId}) {
    messagesStream['roomId'] = supabase.from('messages').stream(primaryKey: ['id']).eq('room_id', roomId).order('created_at').limit(1)
        // Map the stream into Messages
        .map<Message?>((data) => data.isEmpty? null : Message.fromMap(map: data.first, myUserId: userId))
        // Listen for changes 
        .listen((message) {   
          // Set the newest message 
          final index = rooms.indexWhere((room) => room.id == roomId);
          if(index == -1) {
            return;
          } 

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

  @override void dispose() {
    roomsSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    List<Profile>? currentProfileData = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    
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
          DrawerHeader(child: Avatar(profile: widget.userProfile, radius: 50, fontSize: 40)),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(leading: const Icon(Icons.account_circle_outlined), title: const Text('Edit Account'), onTap: () => Navigator.of(context).push(ProfilePage.route(widget.userProfile!)))
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