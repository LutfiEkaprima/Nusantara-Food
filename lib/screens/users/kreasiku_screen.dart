import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/diterima_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/ditinjau_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/ditolak_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/draft_view.dart';
import 'package:nusantara_food/screens/users/tambahresep.dart';

class KreasikuScreen extends StatefulWidget {
  const KreasikuScreen({super.key});

  @override
  _KreasikuScreenState createState() => _KreasikuScreenState();
}

class _KreasikuScreenState extends State<KreasikuScreen> {
  late Future<bool> _isUserGuest;

  Future<bool> _checkUserStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return doc.data()?.containsKey('status') == true && doc['status'] == 'guest';
      }
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _isUserGuest = _checkUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserGuest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading user status')),
          );
        }

        if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Tidak Memiliki Akses'),
                  content: const Text('Silahkan Login untuk mengakses fitur ini.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                );
              },
            );
          });

          return const Scaffold(
            body: Center(child: Text('Silahkan Login terlebih dahulu untuk mengakses halaman ini.', textAlign: TextAlign.center,)),
          );
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFFED),
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'Resep Masakanku',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFFFFFED),
              automaticallyImplyLeading: false,
              bottom: const TabBar(
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'DRAFT'),
                  Tab(text: 'DITINJAU'),
                  Tab(text: 'DITERIMA'),
                  Tab(text: 'DITOLAK'),
                ],
                labelColor: Colors.black,
                indicatorColor: Color.fromARGB(255, 255, 0, 0),
              ),
            ),
            body: const TabBarView(
              children: [
                DraftView(),
                DitinjauView(),
                DiterimaView(),
                DitolakView(),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahResep()),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
