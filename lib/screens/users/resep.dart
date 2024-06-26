import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/utils.dart';

class ResepScreen extends StatefulWidget {
  const ResepScreen({super.key});

  @override
  _ResepScreenState createState() => _ResepScreenState();
}

class _ResepScreenState extends State<ResepScreen> {
  List<Map<String, dynamic>> savedRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipes();
  }

  Future<void> _fetchSavedRecipes() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('savedRecipes')
            .get();
        setState(() {
          savedRecipes = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            data['isSaved'] =
                true; // Set isSaved to true since it's from savedRecipes
            return data;
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching saved recipes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSaveRecipe(Map<String, dynamic> recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference recipeRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedRecipes')
          .doc(recipe['docId']);

      DocumentSnapshot recipeSnapshot = await recipeRef.get();

      if (recipeSnapshot.exists) {
        await recipeRef.delete();
        setState(() {
          recipe['isSaved'] = false; // Set isSaved to false when deleting
          savedRecipes.removeWhere((r) => r['docId'] == recipe['docId']);
        });
      } else {
        await recipeRef.set(recipe);
        setState(() {
          recipe['isSaved'] = true; // Set isSaved to true when adding
          savedRecipes.add(recipe);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Resep Yang Disimpan',
          style: textStyle(20, Colors.black, FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedRecipes.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada resep yang disimpan',
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = savedRecipes[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewResep(docId: recipe['docId']),
                            ),
                          );
                        },
                        child: RecipeCard(
                          recipe: recipe,
                          onToggleSave: () => _toggleSaveRecipe(recipe),
                        ),
                      );
                    },
                    itemCount: savedRecipes.length,
                  ),
                ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onToggleSave;

  RecipeCard({required this.recipe, required this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe['imageUrl'] ??
        'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82';
    final title = recipe['title'] ?? 'No title';
    final publisherName = recipe['publisherName'] ?? 'Unknown';
    final rating = recipe['overallRating']?.toString() ?? 'N/A';
    final bool isSaved = recipe['isSaved'] ?? false; // Default to false if null

    final truncatedPublisherName = publisherName.length > 15
        ? '${publisherName.substring(0, 15)}...'
        : publisherName;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10.0)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      truncatedPublisherName,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: onToggleSave,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16.0,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
