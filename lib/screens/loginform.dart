import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/users/botnav.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class Loginform extends StatefulWidget {
  final String? email;
  final String? password;

  const Loginform({super.key, this.email, this.password});

  @override
  _LoginformState createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
    _passwordController.text = widget.password ?? '';
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav(initialIndex: 0)),
        );
      }
    } catch (e) {
      print('Login failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingState(
        isLoading: _isLoading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFED),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(22.6, 22, 22.6, 111),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 35.6, 115),
                            child: Text(
                              'Kembali',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xFF035444),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(45, 50, 0, 0),
                          child: Image.asset(
                            'assets/icons/Icon.png',
                            width: 116,
                            height: 116,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Selamat Datang',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF035444),
                  ),
                ),
                SizedBox(height: 43),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF035444),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Password',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF035444),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 42),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF035444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Center(
                        child: Text(
                          'Masuk',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
