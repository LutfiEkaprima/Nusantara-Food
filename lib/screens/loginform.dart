import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _showDialog(String title, String content, {String? userName}) {
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
                    MaterialPageRoute(
                      builder: (context) => BottomNav(initialIndex: 0, userName: userName ?? ''),
                    ),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> fetchUserName(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['nama'];
  }

  Future<bool> isEmailVerified(User user) async {
    await user.reload();
    return user.emailVerified;
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
        bool emailVerified = await isEmailVerified(credential.user!);

        if (!emailVerified) {
          _showDialog('Gagal', 'Email belum diverifikasi. Silakan periksa email Anda untuk verifikasi.');
          await credential.user!.sendEmailVerification();
        } else {
          String? userName = await fetchUserName(credential.user!.uid);
          _showDialog('Berhasil', 'Login berhasil!', userName: userName);
        }
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
      backgroundColor: const Color(0xFFFFFFED),
      body: LoadingState(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22.6, 22, 22.6, 111),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Kembali',
                    style: textStyle(16, const Color(0xFF035444), FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Image.asset(
                  'assets/icons/Icon.png',
                  width: 116,
                  height: 116,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Selamat Datang',
                style: textStyle(16, const Color(0xFF035444), FontWeight.w800),
              ),
              const SizedBox(height: 43),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: textStyle(15, const Color(0xFF035444), FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: _emailError.isNotEmpty ? _emailError : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Password',
                    style: textStyle(15, const Color(0xFF035444), FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: _passwordError.isNotEmpty ? _passwordError : null,
                    ),
                  ),
                  const SizedBox(height: 42),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF035444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Center(
                      child: Text(
                        'Masuk',
                        style: textStyle(16, const Color.fromARGB(255, 255, 255, 255), FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _navigateToResetPassword,
                    child: Text(
                      'Lupa Password?',
                      style: textStyle(14, const Color(0xFF035444), FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
