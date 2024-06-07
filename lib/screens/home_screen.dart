import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFED),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0x1A000000)),
                    color: Color(0xFFFFFFED),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 13, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Akun',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF035444),
                          ),
                        ),
                        // Image.asset(
                        //   'assets/Images/gear.png',
                        //   width: 26,
                        //   height: 26,
                        //   fit: BoxFit.contain,
                        // ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(6, 0, 0, 20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/Icon.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'USER',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFF000000),
                        ),
                      ),
                      SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'About',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Color(0xFFE40000),
                            ),
                          ),
                          Text(
                            'Resep Saya',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(color: Color(0x94000000), thickness: 3),
                      SizedBox(height: 36),
                      Divider(color: Color(0xFFFF0000), thickness: 3, indent: 14),
                    ],
                  ),
                ),
                Text(
                  'DESCRIPTION',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 8.5),
                Divider(color: Color(0xFF000000), thickness: 0.5, endIndent: 181),
                SizedBox(height: 24),
                Text(
                  'Saya Awalnya coba - coba, lama - lama malah ketagihan. Sekarang saya sedang membuat resep baru yang tak kalah enak dari chef Arnold.',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 43),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAVORITE FOOD',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 10.5),
                    Divider(color: Color(0xFF000000), thickness: 0.5, endIndent: 97),
                    Text(
                      'Pudding Lele Albino',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Nasi Kucing Persia',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masakan Mamah Daffa Nur Fakhri',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'HOME',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book),
                      label: 'RESEP',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'PROFILE',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.create),
                      label: 'KREASIKU',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
