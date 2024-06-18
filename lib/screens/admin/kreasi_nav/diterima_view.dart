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
          .where('status', isEqualTo: 'disetujui')
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
      print('Error fetching diterima recipes: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteRecipe(String docId) async {
    try {
      await _firestore.collection('resep').doc(docId).delete();
    } catch (error) {
      print('Error deleting recipe: $error');
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Resep'),
          content: Text('Apakah Anda yakin ingin menghapus resep ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                _deleteRecipe(docId);
                Navigator.of(context).pop();
                _fetchData();
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchDiterima(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(
              isLoading: true,
              child: Container(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada resep yang diterima', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200)));
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
                  subtitle: Text(data['time'] + ' Menit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w200)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Hapus Resep') {
                            _showDeleteDialog(documents[index].id);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Hapus Resep'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
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
