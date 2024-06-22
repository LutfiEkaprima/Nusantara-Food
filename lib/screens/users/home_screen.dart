import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nusantara_food/providers/save_resep_provider.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:nusantara_food/utils.dart';
import 'package:nusantara_food/widgets/loadingstate.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

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
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchApprovedRecipes();
    _searchController.addListener(_searchRecipes);
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
      print('Error fetching approved recipes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                            'Halo, ${widget.userName}',
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
              ),
              Section(
                title: 'MENU SARAPAN',
                recipes: breakfastRecipes,
              ),
              Section(
                title: 'MENU MAKAN SIANG',
                recipes: lunchRecipes,
              ),
              Section(
                title: 'MENU MAKAN MALAM',
                recipes: dinnerRecipes,
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

  const Section({super.key, required this.title, required this.recipes});

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
                    recipe['imageUrl'] ?? 'https://via.placeholder.com/150';
                final title = recipe['title'] ?? 'No title';
                final publisherName = recipe['publisherName'] ?? 'Unknown';
                final rating = recipe['overallRating']?.toString() ?? 'N/A';

                final truncatedPublisherName = publisherName.length > 10
                    ? publisherName.substring(0, 15) + '...'
                    : publisherName;

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
                                    Consumer<SavedRecipesProvider>(
                                      builder: (context, savedRecipesProvider,
                                          child) {
                                        bool isSaved = savedRecipesProvider
                                            .isSaved(recipe['docId']);
                                        return IconButton(
                                          icon: Icon(
                                            isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: isSaved
                                                ? Colors.yellow
                                                : Colors.black54,
                                          ),
                                          onPressed: () {
                                            savedRecipesProvider
                                                .toggleRecipe(recipe);
                                          },
                                        );
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
