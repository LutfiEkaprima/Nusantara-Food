import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarUser extends StatelessWidget {
  
  DaftarUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFED),
      resizeToAvoidBottomInset: true,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(22.6, 22, 22.6, 61),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 18),
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
                                margin: EdgeInsets.fromLTRB(0, 0, 35.6, 0),
                                child: Text(
                                  'Kembali',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF035444),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(0, 50, 100, 0),
                                child: Image.asset(
                                  'assets/icons/Icon.png',
                                  width: 116,
                                  height: 116,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 1, 25),
                      child: Text(
                        'Mohon Mengisi data berikut untuk proses pendaftaran',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF035444),
                        ),
                      ),
                    ),
                    DaftarForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DaftarForm extends StatefulWidget {
  @override
  _DaftarFormState createState() => _DaftarFormState();
}

class _DaftarFormState extends State<DaftarForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_namaController, 'Nama Lengkap'),
          _buildTextField(_emailController, 'Email'),
          _buildTextField(_passwordController, 'Password', obscureText: true),
          _buildTextField(_konfirmasiPasswordController, 'Masukkan Password kembali', obscureText: true),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(18, 28, 18, 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF035444),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Memastikan kedua password cocok
                  if (_passwordController.text != _konfirmasiPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password tidak cocok'),
                      ),
                    );
                    return;
                  }

                  try {
                    // Membuat pengguna menggunakan Firebase Authentication
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    // Menyimpan data pengguna ke Cloud Firestore
                    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
                      'nama': _namaController.text,
                      'email': _emailController.text,
                    });

                    // Berhasil mendaftar, navigasi ke halaman berikutnya atau tampilkan pesan sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pendaftaran berhasil'),
                      ),
                    );

                  } on FirebaseAuthException catch (e) {
                    // Menangani kesalahan saat pendaftaran
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pendaftaran gagal: ${e.message}'),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'DAFTAR',
                style: GoogleFonts.getFont(
                  'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.getFont(
              'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF035444),
            ),
          ),
          SizedBox(height: 9),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              filled: true,
              fillColor: Color(0xFFFFFFFF),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$labelText tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
