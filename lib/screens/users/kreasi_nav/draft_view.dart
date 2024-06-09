import 'package:flutter/material.dart';

class DraftView extends StatelessWidget {
  const DraftView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.edit,
            size: 100,
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            'DRAFT MASIH KOSONG',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ayo tambahkan resepmu sekarang!',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
