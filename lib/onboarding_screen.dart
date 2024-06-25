import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:nusantara_food/screens/loginmenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFFFFFFED),
      pages: [
        PageViewModel(
          title: "Selamat Datang di Nusantara Food",
          body: "Temukan berbagai resep makanan khas Nusantara.",
          image: Center(child: Image.asset("assets/icons/Icon.png", height: 175.0)),
        ),
        PageViewModel(
          title: "Berbagi Resep",
          body: "Bagikan resep favoritmu dengan komunitas.",
          image: Center(child: Image.asset("assets/icons/Icon.png", height: 175.0)),
        ),
        PageViewModel(
          title: "Simpan Resep",
          body: "Simpan resep untuk melihatnya di kemudian hari.",
          image: Center(child: Image.asset("assets/icons/Icon.png", height: 175.0)),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
