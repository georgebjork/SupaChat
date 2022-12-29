import 'dart:async';
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/components/start_chat_bar.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/theme_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/profile_page.dart';
import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/display_chats.dart';

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
    print('Called Profiles Load');

    // Grab all profiles 
    final List<dynamic> data = await supabase.from('profiles').select();
    currentProfileData = data.map((index) => Profile.fromMap(index)).toList();
    
    // Get the user profile
    int index = currentProfileData.indexWhere((element) => element.id == userId);

    // Trigger re render to give the drawer the user info without it being null
    setState(() {
      userProfile = currentProfileData[index];

      // Remove user from the profiles array since it will not be needed
      currentProfileData.removeAt(index);
    });
  }
  // This will load all of the rooms for user from the database
  Future<void> loadRooms() async {
    if(hasLoadRoomsCalled){
      return;
    }
    hasLoadRoomsCalled = true;
    print('Called Rooms Load');
    // Grab all of the rooms we are a part of.
    final List<dynamic> currentRooms = await supabase.from('room_participants').select().neq('profile_id', userId);
    currentRoomData = currentRooms.map((index) => Room.fromRoomParticipants(index)).toList();

    //setState(() {});
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