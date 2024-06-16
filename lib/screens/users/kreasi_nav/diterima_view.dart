import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class DiterimaView extends StatefulWidget {
  DiterimaView({super.key});

  @override
  _DiterimaViewState createState() => _DiterimaViewState();
}

class _DiterimaViewState extends State<DiterimaView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  Future<QuerySnapshot> _fetchDiterima() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection('resep')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'diterima')
          .get();
    } else {
      return Future.error('User not logged in');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fetchDiterima();
    } catch (error) {
      print('Error fetching ditinjau recipes: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchDiterima(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(
              isLoading: true,
              child: Container(), // Empty container to show loading animation
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada resep yang ditinjau'));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return LoadingState(
            isLoading: _isLoading,
            child: ListView.builder(
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
            ),
          );
        },
      ),
    );
  }
}
