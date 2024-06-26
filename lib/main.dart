import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_food/onboarding_screen.dart';
import 'package:nusantara_food/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusantara_food/screens/users/botnav.dart';
import 'package:nusantara_food/screens/users/home_screen.dart';
import 'package:nusantara_food/screens/users/resep.dart';
import 'package:nusantara_food/screens/loginmenu.dart';
import 'package:nusantara_food/screens/reset_password.dart';
import 'package:nusantara_food/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkOnboardingStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? onboardingComplete = prefs.getBool('onboardingComplete');

    setState(() {
      _isOnboardingComplete = onboardingComplete ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Montserrat',
            textTheme: GoogleFonts.montserratTextTheme()
          ),
          home: SplashScreen(), // Ganti dengan SplashScreen
          routes: {
            '/bottomnav': (context) => const BottomNav(initialIndex: 0, userName: ''),
            '/reset_password': (context) => const ResetPasswordPage(),
            '/home': (context) => const HomeScreen(),
            '/resep': (context) => const ResepScreen(),
            '/login': (context) => const LoginPage(),
            '/onboarding': (context) => OnboardingScreen(), // Route untuk onboarding screen
          },
        );
    }
  }
}
