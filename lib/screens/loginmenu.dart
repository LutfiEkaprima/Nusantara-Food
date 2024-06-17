import 'package:flutter/material.dart';
import 'package:nusantara_food/screens/daftar.dart';
import 'package:nusantara_food/utils.dart';
import 'loginform.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.9),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double containerSize = constraints.maxWidth * 0.5;
              double textSize = constraints.maxWidth * 0.04;
              double buttonWidth = constraints.maxWidth * 0.5;
              double buttonHeight = constraints.maxHeight * 0.07;

              if (constraints.maxWidth < 600) {
                containerSize = 183;
                textSize = 16;
                buttonWidth = 205;
                buttonHeight = 50;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    width: containerSize,
                    height: containerSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/icons/Icon.png'),
                      ),
                    ),
                  ),
                  Text(
                    'SELAMAT DATANG DI NUSANTARA FOOD',
                    textAlign: TextAlign.center,
                    style: textStyle(textSize, const Color(0xFF035444), FontWeight.w800),
                  ),
                  const SizedBox(height: 47),
                  SizedBox(
                    width: buttonWidth,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF035444),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Loginform()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                              alignment: Alignment.center,
                              child: Text(
                                'MASUK',
                                style: textStyle(16, const Color.fromARGB(255, 255, 255, 255), FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF035444),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DaftarUser()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                              alignment: Alignment.center,
                              child: Text(
                                'DAFTAR',
                                style: textStyle(16, const Color.fromARGB(255, 255, 255, 255), FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Masuk sebagai ',
                      style: textStyle(14, const Color(0xFF035444), FontWeight.w800),
                      children: [
                        TextSpan(
                          text: 'Tamu',
                          style: textStyle(14, const Color(0xFF035444), FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
