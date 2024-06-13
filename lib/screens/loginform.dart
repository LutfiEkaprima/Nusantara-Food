import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/reset_password.dart';
import 'package:nusantara_food/screens/users/botnav.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';
import 'package:nusantara_food/utils.dart';

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
  String _emailError = '';
  String _passwordError = '';

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
    _passwordController.text = widget.password ?? '';
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Berhasil') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BottomNav(initialIndex: 0)),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email tidak boleh kosong';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (credential.user != null) {
        _showDialog('Berhasil', 'Login berhasil!');
      }
    } catch (e) {
      String errorMessage = 'Login gagal: ';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Email tidak valid';
            break;
          default:
            errorMessage = 'Password atau Email salah. Silakan coba lagi.';
            break;
        }
      }
      _showDialog('Gagal', errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
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
                              style: textStyle(16, Color(0xFF035444), FontWeight.w800)
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
                  style: textStyle(16, Color(0xFF035444), FontWeight.w800),
                ),
                SizedBox(height: 43),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: textStyle(15, Color(0xFF035444), FontWeight.w800),
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
                        errorText: _emailError.isNotEmpty ? _emailError : null,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Password',
                      style: textStyle(15, Color(0xFF035444), FontWeight.w800),
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
                        errorText: _passwordError.isNotEmpty ? _passwordError : null,
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
                          style: textStyle(16, Color.fromARGB(255, 255, 255, 255), FontWeight.w800),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToResetPassword,
                      child: Text(
                        'Lupa Password?',
                        style: textStyle(14, Color(0xFF035444), FontWeight.w600),
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
