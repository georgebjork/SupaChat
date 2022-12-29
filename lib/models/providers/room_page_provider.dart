
import 'dart:async';

import 'package:chat_app/models/Message.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class RoomPageProvider extends ChangeNotifier {
  
  // List of available profiles to message
  List<Profile> profiles = [];

  // List of rooms you are a part of
  List<Room> rooms = [];

  // Subscripton of rooms and a stream
  StreamSubscription<List<Room>>? roomsSubscription; 
  Stream<List<Room>>? roomsStream; 

  //Message data
  final Map<String, StreamSubscription<Message?>> messagesStream = {};

  //User id
  final String userId = supabase.auth.currentUser!.id;


  // +----------------------------------------------+ //
  //                   FUNCTIONS                      //
  // +----------------------------------------------+ //


  // This will sort the rooms based on the time of the last message
  void sortRooms(){
    // This should be moved into its own function. It should be used when rooms are also created. It should also sort and then render
    rooms.sort((a, b) {
      // Sort according to the last message
      // Use the room createdAt when last message is not available
      final aTimeStamp = a.lastMessage != null ? a.lastMessage!.createdAt : a.createdAt;
      final bTimeStamp = b.lastMessage != null ? b.lastMessage!.createdAt : b.createdAt;
      return bTimeStamp.compareTo(aTimeStamp);
    });
    
    // Trigger re-render to show updated state
    notifyListeners();
  }

  // This will set a listener on the rooms to recognize when updates have happened.
  Future<void> setRoomsListener() async {
    // Listen to the stream and map it into a list of rooms
    roomsStream = supabase.from('room_participants').stream(primaryKey: ['room_id', 'profile_id']).neq('profile_id', userId)
      .map((listOfRooms) => rooms = listOfRooms.map((e) => Room.fromRoomParticipants(e)).toList());
    
    // Now we want to listen to the stream with a subscription. If we hear a change, we want to do something. In this case, set a listener for new messages
    roomsSubscription = roomsStream?.listen(
      // Get the newest data
      (listOfRooms) async {
        print('Room Listener Called!');
        for (final room in rooms) {
          getNewestMessage(roomId: room.id);
        }
      },
      onError: (err) => print(err.toString()), //context.showErrorSnackBar(message: err.toString()),
      onDone: () => print('Done!')
    ); 
  }

  // This will get the newest message based on the room id. It will then set a listener for any changes of the message
  void getNewestMessage({required roomId}) {
    messagesStream['roomId'] = supabase.from('messages').stream(primaryKey: ['id']).eq('room_id', roomId).order('created_at').limit(1)
        // Map the stream into Messages
        .map<Message?>((data) => data.isEmpty? null : Message.fromMap(map: data.first, myUserId: userId))
        // Listen for changes 
        .listen((message) {   
           print('Message Listener Called!');
          // Set the newest message 
          final index = rooms.indexWhere((room) => room.id == roomId);
          if(index == -1) {
            return;
          } 

          rooms[index] = rooms[index].copyWith(lastMessage: message);
          sortRooms();
        });
  }
}