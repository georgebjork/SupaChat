
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/profile.dart';
import 'package:chat_app/models/providers/room_page_provider.dart';
import 'package:chat_app/models/room.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/rooms_page.dart';

import '../utils/constants.dart';

class SearchProfiles extends StatefulWidget {
  const SearchProfiles({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const SearchProfiles());
  }

  @override
  State<SearchProfiles> createState() => _SearchProfilesState();
}

class _SearchProfilesState extends State<SearchProfiles> {

  // This will be our constant data
  List<Profile> profiles = [];
  // This will be our search result data
  List<Profile> searchResults = [];

  final _queryController = TextEditingController();


  void filterSearchResults(String query){
    // If our query has something, lets search
    if(query.isNotEmpty) {

      for (var element in profiles) {
        if(element.username.contains(query)) {
          if(!searchResults.contains(element)) {
            searchResults.add(element);
          }
        }
      }
    } 

    else {
      searchResults.clear();
    }

    setState(() {});
  }

  @override
  void initState() {
    // Set the inital data
    profiles = Provider.of<RoomPageProvider>(context, listen: false).profiles;
    super.initState();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Profiles'),
        iconTheme: Theme.of(context).iconTheme
      ),

      body: Column(  
        children: [
          //Search bar here
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => filterSearchResults(value),
              controller: _queryController,
              decoration: const InputDecoration(
                label: Text('Search')
              ),
            ),
          ),

          // List of all profiles
          const SizedBox(height: 10),
          
          Expanded(                             // If search results is empty, then display all profiles, otherwise just do search results
            child: DisplaySearchResults(results: (searchResults.isEmpty)? profiles : searchResults)
          )
        ],
      ),
    );
  }
}


class DisplaySearchResults extends StatelessWidget {

  List<Profile> results = [];

  DisplaySearchResults({
    Key? key,
    required this.results,
  }) : super(key: key);

  Future<String> createRoom(String otherUserId) async {
    final data = await supabase.rpc('create_new_room',
      params: {'other_user_id': otherUserId});
    return data as String;
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {  
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10,10,10,0),
          child: Card(
            child: ListTile(
              onTap: () async {
                List<Room> rooms = Provider.of<RoomPageProvider>(context, listen: false).rooms;
                // Get a room id from function 
                String roomId = await createRoom(results[index].id);

                // pop this page from nav and then nav to the chat page
                Navigator.of(context).push(ChatPage.route(roomId, results[index]));
              },
              leading: Avatar(profile: results[index]),
              // If the name is not null, then we will return the full name. Otherwise just user name 
              title: Text(results[index].getName() ?? results[index].username),
              subtitle: Text('@${results[index].username}'),
            )
          ),
        );
      },
    );
  }

}
