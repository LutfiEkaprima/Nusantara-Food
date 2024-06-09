import 'package:flutter/material.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180.0),
        child: AppBar(
          shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFFFED),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 50),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HALO, USER',
                          style: textStyle(14, Colors.black, FontWeight.bold),
                        ),
                        Text(
                          'Sudahkah Anda Memasak hari ini?',
                          style: textStyle(12, Colors.black, FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari Resep',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
          children: const [
            Section(title: 'MENU HARI INI'),
            Section(title: 'MENU SARAPAN'),
            Section(title: 'MENU MAKAN SIANG'),
            Section(title: 'MENU MAKAN MALAM'),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;

  const Section({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            title,
            style: textStyle(18, Colors.black, FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewResep()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: 150,
                    margin: const EdgeInsets.only(right: 30.0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
