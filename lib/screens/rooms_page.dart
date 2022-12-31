import 'dart:async';
import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/components/start_chat_bar.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/theme_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/profile_page.dart';
import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/screens/search_profiles.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This will give us access to the provider
    final provider = Provider.of<RoomPageProvider>(context, listen: false);

    return Scaffold(
      drawer: HomeDrawer(),
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

      // Float action button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(SearchProfiles.route()), 
        child: const Icon(Icons.add),
      ),

      // Our body with a future builder
      body: FutureBuilder(
        future: Future.wait([
          // Run these futures from the provider to get inital data
          provider.loadProfiles(),
          provider.setRoomsListener()
        ]),

        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return preloader;
          } 

          else{
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
  
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final themeData = Provider.of<ThemeProvider>(context, listen: false);

    
    return Consumer<RoomPageProvider> (
       builder: (context, provider, child) {
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(child: Avatar(profile: provider.userProfile, radius: 50, fontSize: 40)),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(leading: const Icon(Icons.account_circle_outlined), title: const Text('Edit Account'), onTap: () => Navigator.of(context).push(ProfilePage.route(provider.userProfile!)))
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
    );
    
   
  }
}