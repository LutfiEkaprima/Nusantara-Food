import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nusantara_food/providers/save_resep_provider.dart';
import 'package:nusantara_food/screens/users/home_screen.dart';
import 'package:nusantara_food/screens/users/resep.dart';
import 'package:provider/provider.dart';
import 'package:nusantara_food/firebase_options.dart';
import 'package:nusantara_food/screens/loginmenu.dart';
import 'package:nusantara_food/screens/users/botnav.dart';
import 'package:nusantara_food/screens/reset_password.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedRecipesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
        routes: {
          '/bottomnav': (context) => const BottomNav(initialIndex: 0, userName: ''),
          '/reset_password': (context) => const ResetPasswordPage(),
          '/home': (context) => HomeScreen(userName: ModalRoute.of(context)!.settings.arguments as String),
          '/resep': (context) => const ResepScreen(),
        },
      ),
    );
  }
}

class ResepPage {
}
