import 'package:flutter/material.dart';

class Kreasiku extends StatelessWidget {

  const Kreasiku({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Kreasiku'),
        ),
        body: Center(
          child: Text('Kreasiku'),
        ),
      ),
    );
  }
}