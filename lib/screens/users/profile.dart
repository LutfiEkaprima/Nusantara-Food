import 'package:flutter/material.dart';
import 'package:nusantara_food/screens/users/tambahresep.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(280.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
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

class ResepSayaTab extends StatelessWidget {
  const ResepSayaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
        child: Center(
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
                    MaterialPageRoute(
                        builder: (context) => const TambahResep()),
                  );
                },
                child: const Text('Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('Kelola Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil Saya'),
            onTap: () {
// Handle tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Ubah Email Akun'),
            onTap: () {
// Handle tap
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Info Lainnya',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
            title: Text('Pusat Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title:
                const Text('Keluar Akun', style: TextStyle(color: Colors.red)),
            onTap: () {
// Handle tap
            },
          ),
        ],
      ),
    );
  }
}
