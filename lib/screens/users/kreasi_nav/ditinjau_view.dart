import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DitinjauView extends StatelessWidget {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DitinjauView({super.key}); // Removed 'const'

  Future<QuerySnapshot> _fetchDitinjau() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection('resep')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'ditinjau')
          .get();
    } else {
      return Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchDitinjau(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recipes under review'));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['time']),
                onTap: () {
                  // Navigate to detail page if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
