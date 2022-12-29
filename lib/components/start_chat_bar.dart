import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';

class StartChatBar extends StatelessWidget {
  const StartChatBar({Key? key,}) : super(key: key);

  Future<String> createRoom(String otherUserId) async {
    final data = await supabase.rpc('create_new_room',
      params: {'other_user_id': otherUserId});
    return data as String;
  }

  @override 
  Widget build(BuildContext context){

    List<Profile> profiles = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    List<Room> rooms = Provider.of<RoomPageProvider>(context, listen: false).rooms;
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: profiles.length,
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
                  if(rooms.map((e) => e.id).contains(roomId)) { Navigator.of(context).push(ChatPage.route(roomId, profiles[index])); }
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