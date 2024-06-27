import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/utils.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  List<Map<String, dynamic>> breakfastRecipes = [];
  List<Map<String, dynamic>> lunchRecipes = [];
  List<Map<String, dynamic>> dinnerRecipes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _userName = '';
  User? _currentUser;
  Set<String> savedRecipeIds = <String>{};

  @override
  void initState() {
    super.initState();
    fetchApprovedRecipes();
    _fetchUserName();
    _searchController.addListener(_searchRecipes);
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchSavedRecipes();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _userName = userDoc['nama'] ?? 'User';
        });
      }
    } catch (e) {
      // ignore: avoid_print
    }
  }

  Future<void> _fetchSavedRecipes() async {
    try {
      if (_currentUser != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('savedRecipes')
            .get();
        setState(() {
          savedRecipeIds = snapshot.docs.map((doc) => doc.id).toSet();
        });
      }
    } catch (e) {
      // ignore: avoid_print
    }
  }

  Future<void> fetchApprovedRecipes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('resep')
          .where('status', isEqualTo: 'disetujui')
          .get();
      setState(() {
        allRecipes = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          return data;
        }).toList();

        filteredRecipes = allRecipes;

        breakfastRecipes.clear();
        lunchRecipes.clear();
        dinnerRecipes.clear();

        for (var recipe in allRecipes) {
          List<String> categories =
              List<String>.from(recipe['categories'] ?? []);

          if (categories.contains('sarapan') ||
              categories.contains('SARAPAN') ||
              categories.contains('Makan Pagi') ||
              categories.contains('MAKAN PAGI')) {
            breakfastRecipes.add(recipe);
          }

          if (categories.contains('makan siang') ||
              categories.contains('MAKAN SIANG') ||
              categories.contains('Makan Siang')) {
            lunchRecipes.add(recipe);
          }

          if (categories.contains('makan malam') ||
              categories.contains('MAKAN MALAM') ||
              categories.contains('Makan Malam')) {
            dinnerRecipes.add(recipe);
          }
        }
      });
    } catch (e) {
      // ignore: avoid_print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRecipe(Map<String, dynamic> recipe) async {
    try {
      if (_currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('savedRecipes')
            .doc(recipe['docId'])
            .set(recipe);
        setState(() {
          savedRecipeIds.add(recipe['docId']);
        });
      }
    } catch (e) {
      // ignore: avoid_print
    }
  }

  Future<void> _removeRecipe(String docId) async {
    try {
      if (_currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('savedRecipes')
            .doc(docId)
            .delete();
        setState(() {
          savedRecipeIds.remove(docId);
        });
      }
    } catch (e) {
      // ignore: avoid_print
    }
  }

  void _searchRecipes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        String title = recipe['title']?.toLowerCase() ?? '';
        return title.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingState(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFED),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(180.0),
          child: AppBar(
            shadowColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFFFFFED),
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle, size: 50),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $_userName',
                            style: textStyle(14, Colors.black, FontWeight.bold),
                          ),
                          Text(
                            'Sudahkah Anda Memasak hari ini?',
                            style: textStyle(12, Colors.black, FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari Resep',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: ListView(
            children: [
              Section(
                title: 'MENU HARI INI',
                recipes: filteredRecipes,
                onSaveRecipe: _saveRecipe,
                onRemoveRecipe: _removeRecipe,
                savedRecipeIds: savedRecipeIds,
              ),
              Section(
                title: 'MENU SARAPAN',
                recipes: breakfastRecipes,
                onSaveRecipe: _saveRecipe,
                onRemoveRecipe: _removeRecipe,
                savedRecipeIds: savedRecipeIds,
              ),
              Section(
                title: 'MENU MAKAN SIANG',
                recipes: lunchRecipes,
                onSaveRecipe: _saveRecipe,
                onRemoveRecipe: _removeRecipe,
                savedRecipeIds: savedRecipeIds,
              ),
              Section(
                title: 'MENU MAKAN MALAM',
                recipes: dinnerRecipes,
                onSaveRecipe: _saveRecipe,
                onRemoveRecipe: _removeRecipe,
                savedRecipeIds: savedRecipeIds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> recipes;
  final Function(Map<String, dynamic>) onSaveRecipe;
  final Function(String) onRemoveRecipe;
  final Set<String> savedRecipeIds;

  const Section({
    super.key,
    required this.title,
    required this.recipes,
    required this.onSaveRecipe,
    required this.onRemoveRecipe,
    required this.savedRecipeIds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            title,
            style: textStyle(18, Colors.black, FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];

                final imageUrl =
                    recipe['imageUrl'] ?? 'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82';
                final title = recipe['title'] ?? 'No title';
                final publisherName = recipe['publisherName'] ?? 'Unknown';
                final rating = recipe['overallRating']?.toString() ?? 'N/A';

                final truncatedPublisherName = publisherName.length > 15
                    ? publisherName.substring(0, 15) + '...'
                    : publisherName;

                bool isSaved = savedRecipeIds.contains(recipe['docId']);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewResep(docId: recipe['docId'])),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: 200,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8.0)),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textStyle(
                                    14, Colors.black, FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                truncatedPublisherName,
                                style: textStyle(
                                    12, Colors.black54, FontWeight.normal),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow, size: 16),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      rating,
                                      style: textStyle(12, Colors.black54,
                                          FontWeight.normal),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: isSaved
                                            ? Colors.yellow
                                            : Colors.black54,
                                      ),
                                      onPressed: () {
                                        if (isSaved) {
                                          onRemoveRecipe(recipe['docId']);
                                        } else {
                                          onSaveRecipe(recipe);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
