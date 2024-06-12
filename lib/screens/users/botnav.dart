import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:nusantara_food/screens/users/home_screen.dart';
import 'package:nusantara_food/screens/users/kreasiku_screen.dart';
import 'package:nusantara_food/screens/users/resep.dart';
import 'package:nusantara_food/screens/users/profile.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;

  const BottomNav({super.key, required this.initialIndex});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const KreasikuScreen(),
    const ResepScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: Colors.red,
        height: 60,
        index: _currentIndex,
        items: const <CurvedNavigationBarItem>[
          CurvedNavigationBarItem(
            child: Icon(Icons.home, size: 30),
            label: 'HOME',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.create, size: 30),
            label: 'KREASIKU',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.book, size: 30),
            label: 'RESEP',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person, size: 30),
            label: 'PROFILE',
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