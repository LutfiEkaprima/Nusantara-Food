import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:nusantara_food/screens/admin/kreasiku_screen.dart';
import 'package:nusantara_food/screens/admin/profile.dart';
import 'package:nusantara_food/screens/admin/resep.dart';
import 'package:nusantara_food/screens/admin/home_screen.dart';

class BottomNavadm extends StatefulWidget {
  final int initialIndex;
  final String userName;

  const BottomNavadm({super.key, required this.initialIndex, required this.userName});

  @override
  _BottomNavStateadm createState() => _BottomNavStateadm();
}

class _BottomNavStateadm extends State<BottomNavadm> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreenadm(),
      const KreasikuScreenadm(),
      const ResepScreenadm(),
      const ProfileScreenadm(),
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
