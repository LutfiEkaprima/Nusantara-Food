import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class DitinjauView extends StatefulWidget {
  const DitinjauView({super.key});

  @override
  _DitinjauViewState createState() => _DitinjauViewState();
}

class _DitinjauViewState extends State<DitinjauView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  Future<QuerySnapshot> _fetchDitinjau() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore
          .collection('resep')
          .where('status', isEqualTo: 'ditinjau')
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
      await _fetchDitinjau();
    } catch (error) {
      // ignore: avoid_print
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateRecipeStatus(String docId, String status) async {
    try {
      if (status == 'diterima') {
        await _firestore.collection('resep').doc(docId).update({
          'status': status,
        });
      } else {
        await _firestore.collection('resep').doc(docId).update({'status': status});
      }
    } catch (error) {
      // ignore: avoid_print
    }
  }

  void _showActionDialog(String docId, String action) {
    String title;
    String content;
    String newStatus;

    switch (action) {
      case 'Batalkan Pengajuan':
        title = 'Batalkan Pengajuan';
        content = 'Apakah Anda yakin ingin membatalkan pengajuan ini?';
        newStatus = 'batal';
        break;
      case 'Setujui Resep':
        title = 'Setujui Resep';
        content = 'Apakah Anda yakin ingin menyetujui resep ini?';
        newStatus = 'disetujui';
        break;
      case 'Tolak Resep':
        title = 'Tolak Resep';
        content = 'Apakah Anda yakin ingin menolak resep ini?';
        newStatus = 'ditolak';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                _updateRecipeStatus(docId, newStatus);
                Navigator.of(context).pop();
                _fetchData();
              },
              child: const Text('Ya'),
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
        future: _fetchDitinjau(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(
              isLoading: true,
              child: Container(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak Pengajuan Resep', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200)));
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
                      const Icon(Icons.circle, color: Colors.yellow, size: 12),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          _showActionDialog(documents[index].id, value);
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Setujui Resep', 'Tolak Resep'}
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewResep(docId: documents[index].id),
                      ),
                    );
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
