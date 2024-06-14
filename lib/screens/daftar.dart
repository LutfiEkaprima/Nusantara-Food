import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nusantara_food/utils.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';
import 'loginform.dart'; 

class DaftarUser extends StatefulWidget {
  const DaftarUser({super.key});

  @override
  _DaftarUserState createState() => _DaftarUserState();
}

class _DaftarUserState extends State<DaftarUser> {
  bool _isLoading = false;

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      resizeToAvoidBottomInset: true,
      body: LoadingState(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22.6, 22, 22.6, 61),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 18),
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
                                margin: const EdgeInsets.fromLTRB(0, 0, 35.6, 0),
                                child: Text(
                                  'Kembali',
                                  style: textStyle(16, const Color(0xFF035444), FontWeight.w800),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.fromLTRB(0, 50, 100, 0),
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
                      margin: const EdgeInsets.fromLTRB(0, 0, 1, 25),
                      child: Text(
                        'Mohon mengisi data berikut untuk proses pendaftaran',
                        textAlign: TextAlign.center,
                        style: textStyle(16, const Color(0xFF035444), FontWeight.w800),
                      ),
                    ),
                    DaftarForm(setLoading: setLoading),
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
  final Function(bool) setLoading;

  const DaftarForm({super.key, required this.setLoading});

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
            margin: const EdgeInsets.fromLTRB(18, 28, 18, 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF035444),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_passwordController.text != _konfirmasiPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password tidak cocok'),
                      ),
                    );
                    return;
                  }

                  widget.setLoading(true);

                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
                      'nama': _namaController.text,
                      'email': _emailController.text,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pendaftaran berhasil'),
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Loginform()),
                    );

                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pendaftaran gagal: ${e.message}'),
                      ),
                    );
                  } finally {
                    widget.setLoading(false);
                  }
                }
              },
              child: Text(
                'DAFTAR',
                style: textStyle(16, const Color.fromARGB(255, 255, 255, 255), FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: textStyle(14, const Color(0xFF035444), FontWeight.w800),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
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
