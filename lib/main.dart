import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nusantara_food/firebase_options.dart';
import 'package:nusantara_food/screens/loginmenu.dart';
import 'package:nusantara_food/screens/users/botnav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/bottomnav': (context) => const BottomNav(initialIndex: 0),
      },
    );
  }
}
