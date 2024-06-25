import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:nusantara_food/screens/users/home_screen.dart';
import 'package:nusantara_food/screens/users/kreasiku_screen.dart';
import 'package:nusantara_food/screens/users/resep.dart';
import 'package:nusantara_food/screens/users/profile.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  final String userName;

  const BottomNav({super.key, required this.initialIndex, required this.userName});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      const KreasikuScreen(),
      const ResepScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color.fromARGB(0, 255, 255, 255),
        color: Colors.white,
        buttonBackgroundColor: Color.fromARGB(255, 0, 195, 255),
        height: 60,
        index: _currentIndex,
        items: const <CurvedNavigationBarItem>[
          CurvedNavigationBarItem(
            child: Icon(Icons.home, size: 30),
            label: 'HOME',
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.create, size: 30),
            label: 'KREASIKU',
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.book, size: 30),
            label: 'RESEP',
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person, size: 30),
            label: 'PROFILE',
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
