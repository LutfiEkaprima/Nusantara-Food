import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/users/pengaturan_screen/change_password.dart';
import 'package:nusantara_food/screens/users/pengaturan_screen/profile_edit.dart';
import 'package:nusantara_food/screens/users/tambahresep.dart';
import 'package:nusantara_food/screens/viewresep.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final data = await fetchUserData();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data();
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(280.0),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFFED),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                if (result == true) {
                  _fetchUserData();
                }
              },
            ),
          ],
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _userData?['fotoProfil'] != null
                    ? NetworkImage(_userData!['fotoProfil']) 
                    : null,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                _userData?['nama'] ?? 'USER',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Resep Saya'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AboutTab(userData: _userData),
          const ResepSayaTab(),
        ],
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AboutTab({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['deskripsi'] ?? 'No description available.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            'FAVORITE FOOD',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['favoriteFood'] != null
                ? (userData!['favoriteFood'] as List<dynamic>).join('\n')
                : 'No favorite food listed.',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ResepSayaTab extends StatefulWidget {
  const ResepSayaTab({super.key});

  @override
  _ResepSayaTabState createState() => _ResepSayaTabState();
}

class _ResepSayaTabState extends State<ResepSayaTab> {
  List<Map<String, dynamic>> userRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRecipes();
  }

  Future<void> fetchUserRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('resep')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'disetujui')
            .get();
        setState(() {
          userRecipes = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            return data;
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching user recipes: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after data is loaded
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No recipes yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start adding your favorite recipes here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahResep()),
                );
              },
              child: const Text('Add Recipe'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: userRecipes.length,
      itemBuilder: (context, index) {
        final recipe = userRecipes[index];
        final imageUrl = recipe['imageUrl'] ?? 'https://via.placeholder.com/150';
        final title = recipe['title'] ?? 'No title';
        final publisherName = recipe['publisherName'] ?? 'Unknown';
        final rating = recipe['rating']?.toString() ?? 'N/A';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewResep(docId: recipe['docId'])),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(title),
              subtitle: Text('By $publisherName\nRating: $rating'),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('Kelola Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profil Saya'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileEdit()),
              );

              Navigator.pop(context, result);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Ubah Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Info Lainnya', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang Food Nusantara'),
            onTap: () {
              // Handle tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Kebijakan Privasi'),
            onTap: () {
              // Handle tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Pertanyaan Umum'),
            onTap: () {
              // Handle tap
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Pusat Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Keluar Akun', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}