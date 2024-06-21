import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/admin/pengaturan_screen/change_password.dart';
import 'package:nusantara_food/screens/admin/pengaturan_screen/profile_edit.dart';
import 'package:nusantara_food/screens/admin/tambahresep.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/utils.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class ProfileScreenadm extends StatefulWidget {
  const ProfileScreenadm({super.key});

  @override
  _ProfileScreenadmState createState() => _ProfileScreenadmState();
}

class _ProfileScreenadmState extends State<ProfileScreenadm>
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
          .collection('admin')
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
    return LoadingState(
        isLoading: _isLoading,
        child: Scaffold(
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
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
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
                    style: textStyle(20, Colors.black, FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    controller: _tabController,
                    labelStyle: textStyle(14, Colors.black, FontWeight.w600),
                    tabs: const [
                      Tab(text: 'About 123'),
                      Tab(text: 'Resep Saya'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: LoadingState(
            isLoading: _isLoading,
            child: TabBarView(
              controller: _tabController,
              children: [
                AboutTab(userData: _userData),
                const ResepSayaTab(),
              ],
            ),
          ),
        )
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
          Text(
            'DESCRIPTION',
            style: textStyle(16, Colors.black, FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['deskripsi'] ?? 'No description available.',
            style: textStyle(14, Colors.black, FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Text(
            'FAVORITE FOOD',
            style: textStyle(16, Colors.black, FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['favoriteFood'] != null
                ? (userData!['favoriteFood'] as List<dynamic>).join('\n')
                : 'No favorite food listed.',
            style: textStyle(14, Colors.black, FontWeight.w500),
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingState(
      isLoading: _isLoading,
      child: userRecipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No recipes yet! 123',
                    style: textStyle(18, Colors.black, FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start adding your favorite recipes here.',
                    textAlign: TextAlign.center,
                    style: textStyle(16, Colors.grey, FontWeight.bold),
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: userRecipes.length,
              itemBuilder: (context, index) {
                final recipe = userRecipes[index];
                final imageUrl =
                    recipe['imageUrl'] ?? 'https://via.placeholder.com/150';
                final title = recipe['title'] ?? 'No title';
                final publisherName = recipe['publisherName'] ?? 'Unknown';
                final rating = recipe['rating']?.toString() ?? 'N/A';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewResep(docId: recipe['docId'])),
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
                      title: Text(title,
                          style: textStyle(16, Colors.black, FontWeight.w600)),
                      subtitle: Text('By $publisherName\nRating: $rating'),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
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
        title: Text(
          'Pengaturan',
          style: textStyle(18, Colors.black, FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('Kelola Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              'Edit Profil Saya',
              style: textStyle(16, Colors.black, FontWeight.w500),
            ),
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
            title: Text(
              'Ubah Password',
              style: textStyle(16, Colors.black, FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Info Lainnya',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              'Tentang Nusantara Food',
              style: textStyle(16, Colors.black, FontWeight.w500),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Tentang Nusantara Food'),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: [
                          Text(
                            'Tentang Aplikasi Resep Makanan\n\n'
                            'Aplikasi Nusantara Food adalah sebuah platform yang dirancang untuk membantu pengguna menemukan, menyimpan, dan membagikan berbagai resep makanan dari seluruh dunia. Aplikasi ini menyediakan fitur-fitur unggulan yang memudahkan pengguna dalam mencari resep berdasarkan bahan, kategori, atau popularitas, serta memungkinkan pengguna untuk menambahkan resep mereka sendiri.\n\n'
                            'Tujuan Pengembangan Aplikasi\n\n'
                            'Aplikasi ini dikembangkan sebagai bagian dari tugas mata kuliah Rekayasa Perangkat Lunak. Tujuan utamanya adalah untuk mempraktikkan keterampilan pengembangan perangkat lunak, mulai dari perencanaan, desain, pengembangan, hingga pengujian dan peluncuran aplikasi. Proyek ini memberikan kesempatan bagi kami untuk mengaplikasikan teori dan konsep yang telah dipelajari selama perkuliahan dalam sebuah proyek nyata yang bermanfaat.\n\n'
                            'Dosen Pengampu: YUSTINA SRI SUHARINI, S.T., M.T.\n\n'
                            'Universitas: INSTITUT TEKNOLOGI INDONESIA\n\n'
                            'Proyek ini dibimbing oleh dosen pengampu kami, YUSTINA SRI SUHARINI, S.T., M.T., yang telah memberikan arahan dan dukungan sepanjang proses pengembangan aplikasi.\n\n'
                            'Nama Kelompok: SATORU FOUNDATION\n\n'
                            'Aplikasi ini dikembangkan oleh kelompok kami yang terdiri dari:\n\n'
                            'RIDHUAN RANGGA KUSUMA - 1152200025 (Project Manager)\n'
                            'DAFFA NUR FAKHRI - 1152200027 (Data Analyst)\n'
                            'JONATHAN NATANNAEL ZEFANYA - 1152200024 (Desainer)\n'
                            'LUTFI EKAPRIMA JANNATA - 1152200006 (Programmer)\n\n'
                            'Fitur Utama Aplikasi:\n\n'
                            'Pencarian Resep: Cari resep berdasarkan bahan, kategori, atau popularitas.\n'
                            'Favorit dan Simpan Resep: Simpan resep favorit Anda untuk akses mudah di kemudian hari.\n'
                            'Tambah Resep: Tambahkan dan bagikan resep Anda sendiri dengan komunitas.\n'
                            'Rating dan Ulasan: Berikan rating dan ulasan pada resep yang Anda coba.\n'
                            'Filter Kategori: Filter resep berdasarkan kategori seperti makanan pembuka, utama, penutup, dan lain-lain.\n\n'
                            'Kesimpulan\n\n'
                            'Kami berharap aplikasi ini tidak hanya memenuhi kebutuhan pengguna akan resep makanan yang beragam dan mudah diakses, tetapi juga menjadi contoh nyata dari hasil belajar dan kerja keras kami selama mengikuti mata kuliah Rekayasa Perangkat Lunak. Kami sangat menghargai dukungan dan bimbingan dari dosen pengampu serta kolaborasi yang solid dari seluruh anggota kelompok.',
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(
              'Kebijakan Privasi',
              style: textStyle(16, Colors.black, FontWeight.w500),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Kebijakan Privasi'),
                    content: const SingleChildScrollView(
                      child: Text('Kebijakan Privasi\n\n'
                          'Terakhir diperbarui: 17 Juni 2024\n\n'
                          'Kami di Nusantara Food menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. '
                          'Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat Anda menggunakan aplikasi kami.\n\n'
                          '1. Informasi yang Kami Kumpulkan\n\n'
                          'Kami dapat mengumpulkan informasi berikut saat Anda menggunakan aplikasi kami:\n\n'
                          'Informasi Pribadi: Nama, alamat email, dan informasi lain yang Anda berikan saat mendaftar.\n'
                          'Data Penggunaan: Informasi tentang cara Anda menggunakan aplikasi, termasuk interaksi Anda dengan resep, waktu penggunaan, dan preferensi Anda.\n\n'
                          '2. Penggunaan Informasi\n\n'
                          'Informasi yang kami kumpulkan digunakan untuk:\n\n'
                          'Memberikan Layanan: Mengelola akun Anda, menyediakan resep yang dipersonalisasi, dan meningkatkan pengalaman pengguna.\n'
                          'Komunikasi: Mengirimkan pembaruan, pemberitahuan, dan informasi terkait layanan.\n'
                          'Analisis dan Peningkatan: Menganalisis penggunaan aplikasi untuk meningkatkan fitur dan fungsionalitas.\n'
                          'Keamanan: Melindungi data Anda dan mencegah aktivitas yang tidak sah atau berbahaya.\n\n'
                          '3. Pembagian Informasi\n\n'
                          'Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga kecuali:\n\n'
                          'Dengan persetujuan Anda.\n'
                          'Untuk mematuhi hukum atau proses hukum yang berlaku.\n'
                          'Untuk melindungi hak, properti, atau keselamatan kami atau pengguna lain.\n\n'
                          '4. Penyimpanan dan Keamanan\n\n'
                          'Kami menggunakan langkah-langkah keamanan yang sesuai untuk melindungi informasi Anda dari akses, perubahan, pengungkapan, atau penghancuran yang tidak sah. Namun, tidak ada metode transmisi melalui internet atau metode penyimpanan elektronik yang sepenuhnya aman.\n\n'
                          '5. Hak Anda\n\n'
                          'Anda memiliki hak untuk:\n\n'
                          'Mengakses dan memperbarui informasi pribadi Anda.\n'
                          'Meminta penghapusan informasi pribadi Anda.\n'
                          'Menolak atau membatasi pemrosesan data pribadi Anda.\n'
                          'Untuk menggunakan hak-hak ini, Anda dapat menghubungi kami di NusantaraFood@gmail.com.\n\n'
                          '6. Perubahan Kebijakan Privasi\n\n'
                          'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan tersebut melalui pemberitahuan di aplikasi atau melalui email.\n\n'
                          '7. Hubungi Kami\n\n'
                          'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami di:\n\n'
                          'NusantaraFood@gmail.com\n'
                          '+62 821-1347-2156\n\n'
                          'Dengan menggunakan aplikasi kami, Anda menyetujui pengumpulan dan penggunaan informasi Anda sebagaimana diuraikan dalam Kebijakan Privasi ini.'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Tutup'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
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
