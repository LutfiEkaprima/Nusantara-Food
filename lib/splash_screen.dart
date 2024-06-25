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

    await Future.delayed(const Duration(seconds: 3));

    if (userId != null) {
      Navigator.of(context).pushReplacementNamed('/bottomnav');
    } else if (onboardingComplete ?? false) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      body: Center(
        child: Image.asset('assets/icons/Icon.png', width: 150, height: 150),
      ),
    );
  }
}
