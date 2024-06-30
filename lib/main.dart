import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkOnboardingStatus();
    _setupFirebaseMessaging();
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

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );


    // Get the token
    String? token = await messaging.getToken();

    setState(() {
      _fcmToken = token;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, '/splash');
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
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/bottomnav': (context) => const BottomNav(initialIndex: 0, userName: ''),
            '/reset_password': (context) => const ResetPasswordPage(),
            '/home': (context) => const HomeScreen(),
            '/resep': (context) => const ResepScreen(),
            '/login': (context) => const LoginPage(),
            '/onboarding': (context) => const OnboardingScreen(),
          },
        );
    }
  }
}
