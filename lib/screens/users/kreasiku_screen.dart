import 'package:flutter/material.dart';

class KreasikuScreen extends StatelessWidget {
  const KreasikuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreasiku'),
      ),
      body: const Center(
        child: Text('Kreasiku Screen'),
      ),
    );
  }
}
