import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/screens/register_page.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/splash_screen_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://osbmixdkeinjhlgsftsf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zYm1peGRrZWluamhsZ3NmdHNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjkxNjI0NTcsImV4cCI6MTk4NDczODQ1N30.5b767rAs3iIEgZ3zFA6CWvpnhUf73uLJch5Gf1GRLpA',
    authCallbackUrlHostname: 'login',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appThemeDark,
      home: const SplashScreen(),
    );
  }
}

