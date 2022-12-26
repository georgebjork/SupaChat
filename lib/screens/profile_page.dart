import 'package:chat_app/components/avatar.dart';
import 'package:chat_app/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  // The user we want to look at
  final Profile userProfile;

  const ProfilePage({ Key? key, required this.userProfile }) : super(key: key);

  static Route<void> route(Profile profile) {
    return MaterialPageRoute(builder: (context) => ProfilePage(userProfile: profile));
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    _firstNameController.text = widget.userProfile.firstName ?? 'null';
    _lastNameController.text = widget.userProfile.lastName ?? 'null';
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? validate(String? str){
    if (str == null || str.isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<void> _update() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      context.showErrorSnackBar(message: "Please fill out all of the fields.");
      return;
    }

    try {
      await supabase.from('profiles').update({'first_name' : _firstNameController.text, 'last_name' : _lastNameController.text}).eq('id', widget.userProfile.id);
      // ignore: use_build_context_synchronously
      context.showSnackBar(message: 'Data updated!');
    } catch (err) {
      context.showErrorSnackBar(message: err.toString());
    }
  }
    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        iconTheme: Theme.of(context).iconTheme
      ),
      body: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Avatar(profile: widget.userProfile, radius: 50, fontSize: 40),
          )),
          Center(child: Text('@${widget.userProfile.username}', style: const TextStyle(fontSize: 24))),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text('User Data', style: TextStyle(fontSize: 24)),
            
            
                  // First name field
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      label: Text('First Name'),
                    ),
            
                    validator: (val) => validate(val)
                  ),
            
            
                  // Last name field 
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      label: Text('Last Name'),
                    ),
            
                    validator: (val) => validate(val)
                  ),
            
                  // Update 
                  const SizedBox(height: 10),
                  Center(child: ElevatedButton(onPressed: _isLoading ? null : _update, child: const Text('Update'))),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
