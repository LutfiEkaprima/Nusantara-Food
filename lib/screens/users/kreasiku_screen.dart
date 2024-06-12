import 'package:flutter/material.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/diterima_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/ditinjau_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/ditolak_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/draft_view.dart';
import 'package:nusantara_food/screens/users/kreasi_nav/revisi_view.dart';
import 'package:nusantara_food/screens/users/tambahresep.dart';

class KreasikuScreen extends StatelessWidget {
  const KreasikuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFED),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Resep Masakanku'),
          backgroundColor: const Color(0xFFFFFFED),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'DRAFT'),
              Tab(text: 'DITINJAU'),
              Tab(text: 'REVISI'),
              Tab(text: 'DITERIMA'),
              Tab(text: 'DITOLAK'),
            ],
            labelColor: Colors.black,
            indicatorColor: Color.fromARGB(255, 255, 0, 0),
          ),
        ),
        body: TabBarView(
          children: [
            DraftView(),
            DitinjauView(),
            RevisiView(),
            DiterimaView(),
            DitolakView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahResep()),
          );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}
