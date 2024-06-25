import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateFromSplashScreen();
  }

  Future<void> _navigateFromSplashScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    bool? onboardingComplete = prefs.getBool('onboardingComplete');

    await Future.delayed(Duration(seconds: 3)); // Simulasi durasi splash screen

    if (userId != null) {
      // User is logged in
      Navigator.of(context).pushReplacementNamed('/bottomnav');
    } else if (onboardingComplete ?? false) {
      // User has completed onboarding
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // User has not completed onboarding
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFED),
      body: Center(
        child: Image.asset('assets/icons/Icon.png', width: 150, height: 150),
      ),
    );
  }
}
