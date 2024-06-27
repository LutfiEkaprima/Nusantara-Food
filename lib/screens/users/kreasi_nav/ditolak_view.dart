import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class DitolakView extends StatefulWidget {
  const DitolakView({super.key});

  @override
  _DitolakViewState createState() => _DitolakViewState();
}

class _DitolakViewState extends State<DitolakView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  Future<QuerySnapshot> _fetchDitolak() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection('resep')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'ditolak')
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
      await _fetchDitolak();
    } catch (error) {
      // ignore: avoid_print
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchDitolak(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(
              isLoading: true,
              child: Container(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada resep yang ditolak', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200)));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return LoadingState(
            isLoading: _isLoading,
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final data = documents[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  subtitle: Text(data['time' ]+ ' Menit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w200)),
                  trailing: const Icon(Icons.circle, color: Colors.red, size: 12),
                  onTap: () {
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
