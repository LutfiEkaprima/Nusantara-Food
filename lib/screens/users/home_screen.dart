import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFED),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(180.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, size: 50),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HALO, USER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Sudahkah Anda Memasak hari ini?',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
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
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Section(title: 'MENU HARI INI'),
            Section(title: 'MENU SARAPAN'),
            Section(title: 'MENU MAKAN SIANG'),
            Section(title: 'MENU MAKAN MALAM'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'KREASIKU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'RESEP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;

  Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.0),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: EdgeInsets.only(right: 30.0),
                color: Colors.grey[300],
              );
            },
          ),
        ),
      ],
    );
  }
}
