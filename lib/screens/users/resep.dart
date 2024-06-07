import 'package:flutter/material.dart';

class ResepScreen extends StatelessWidget {
  const ResepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep'),
      ),
      body: const Center(
        child: Text('Resep Screen'),
      ),
    );
  }
}
