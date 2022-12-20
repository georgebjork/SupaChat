// ignore_for_file: use_build_context_synchronously

import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/rooms_page.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}


class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(RoomsPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
    );
  }
}