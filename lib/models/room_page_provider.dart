
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/room.dart';
import 'package:flutter/cupertino.dart';

class RoomPageProvider extends ChangeNotifier {
  //List of available profiles to message
  List<Profile>? profiles;

  // List of rooms you are a part of
  List<Room>? rooms;

  RoomPageProvider({
    this.profiles,
    this.rooms
  });

  void addRoom(Room room){
    rooms?.add(room);
    notifyListeners();
  }

  void updateRooms(List<Room> rooms){
    this.rooms = rooms;
    notifyListeners();
  }

  void testNotify(){
    notifyListeners();
  }

}