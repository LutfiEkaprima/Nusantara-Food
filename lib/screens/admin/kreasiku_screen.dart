import 'package:flutter/material.dart';
import 'package:nusantara_food/screens/admin/kreasi_nav/diterima_view.dart';
import 'package:nusantara_food/screens/admin/kreasi_nav/ditinjau_view.dart';
import 'package:nusantara_food/screens/admin/kreasi_nav/ditolak_view.dart';
class KreasikuScreenadm extends StatelessWidget {
  const KreasikuScreenadm({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFED),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Resep Masakanku', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xFFFFFFED),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'PENGAJUAN'),
              Tab(text: 'DITERIMA'),
              Tab(text: 'DITOLAK'),
            ],
            labelColor: Colors.black,
            indicatorColor: Color.fromARGB(255, 255, 0, 0),
          ),
        ),
        body: TabBarView(
          children: [
            DitinjauView(),
            DiterimaView(),
            DitolakView(),
          ],
        ),
      ),
    );
  }
}
