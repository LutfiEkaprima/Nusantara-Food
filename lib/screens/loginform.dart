import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusantara_food/screens/admin/botnav.dart';
import 'package:nusantara_food/screens/reset_password.dart';
import 'package:nusantara_food/screens/users/botnav.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';
import 'package:nusantara_food/utils.dart';

class Loginform extends StatefulWidget {
  final String? email;
  final String? password;

  const Loginform({Key? key, this.email, this.password}) : super(key: key);

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

  void _showDialog(String title, String content, {String? userName, String? role}) {
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
                  if (role == 'admin') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavadm(initialIndex: 0, userName: userName ?? ''),
                      ),
                    );
                  } else if (role == 'user' || role == 'anonymous') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNav(initialIndex: 0, userName: userName ?? ''),
                      ),
                    );
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String email) async {
    final userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.data();
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAdminDetails(String email) async {
    final adminQuery = await FirebaseFirestore.instance.collection('admin').where('email', isEqualTo: email).get();
    if (adminQuery.docs.isNotEmpty) {
      return adminQuery.docs.first.data();
    } else {
      return null;
    }
  }

  Future<bool> isEmailVerified(User user) async {
    await user.reload();
    return user.emailVerified;
  }

  Future<void> saveUserInfo(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('email', user.email ?? '');
  }

  Future<void> clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, String?>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? email = prefs.getString('email');
    return {
      'userId': userId,
      'email': email,
    };
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
        await saveUserInfo(credential.user!);
        bool emailVerified = await isEmailVerified(credential.user!);

        if (!emailVerified) {
          _showDialog('Gagal', 'Email belum diverifikasi. Silakan periksa email Anda untuk verifikasi.');
          await credential.user!.sendEmailVerification();
        } else {
          final userDetails = await fetchUserDetails(_emailController.text);
          if (userDetails != null) {
            String? userName = userDetails['nama'];
            String role = userDetails['role'];

            if (role == 'admin') {
              _showDialog('Berhasil', 'Login berhasil sebagai admin!', userName: userName, role: role);
            } else {
              _showDialog('Berhasil', 'Login berhasil!', userName: userName, role: role);
            }
          } else {
            final adminDetails = await fetchAdminDetails(_emailController.text);
            if (adminDetails != null) {
              String? adminName = adminDetails['nama'];
              _showDialog('Berhasil', 'Login berhasil sebagai admin!', userName: adminName, role: 'admin');
            } else {
              _showDialog('Gagal', 'Pengguna tidak ditemukan.');
            }
          }
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

  void _loginAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();

      if (credential.user != null) {
        await saveUserInfo(credential.user!);

        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'role': 'anonymous',
          'nama': 'Guest',
          'deskripsi': '',
          'fotoProfil': 'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82',
          'favoriteFood': [],
          'status': 'guest',
        });

        _showDialog('Berhasil', 'Login sebagai tamu berhasil!', userName: 'Guest', role: 'anonymous');
      }
    } catch (e) {
      _showDialog('Gagal', 'Login gagal: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      hintText: 'Masukkan email Anda',
                      hintStyle: textStyle(12, const Color(0xFFB2B2B2), FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF035444)),
                      ),
                      errorText: _emailError.isNotEmpty ? _emailError : null,
                    ),
                    style: textStyle(14, const Color(0xFF000000), FontWeight.w400),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Password',
                    style: textStyle(15, const Color(0xFF035444), FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      hintText: 'Masukkan password Anda',
                      hintStyle: textStyle(12, const Color(0xFFB2B2B2), FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF035444)),
                      ),
                      errorText: _passwordError.isNotEmpty ? _passwordError : null,
                    ),
                    style: textStyle(14, const Color(0xFF000000), FontWeight.w400),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF035444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Login',
                        style: textStyle(14, const Color(0xFFFFFFFF), FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loginAnonymously,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Color(0xFF035444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Login sebagai Tamu',
                        style: textStyle(14, const Color(0xFF035444), FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToResetPassword,
                      child: Text(
                        'Lupa Password?',
                        style: textStyle(14, const Color(0xFF035444), FontWeight.w700),
                      ),
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
