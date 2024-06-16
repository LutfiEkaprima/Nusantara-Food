import 'package:flutter/material.dart';
import 'package:nusantara_food/providers/save_resep_provider.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:provider/provider.dart';

class ResepScreen extends StatelessWidget {
  
  const ResepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Resep Yang Disimpan'),
      ),
      body: Consumer<SavedRecipesProvider>(
        builder: (context, savedRecipesProvider, child) {
          if (savedRecipesProvider.savedRecipes.isEmpty) {
            return Center(
              child: Text(
                'Belum ada resep yang disimpan',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of boxes in a row
                crossAxisSpacing: 10.0, // Space between the boxes horizontally
                mainAxisSpacing: 10.0, // Space between the boxes vertically
                childAspectRatio: 0.8, // Aspect ratio of each box
              ),
              itemBuilder: (context, index) {
                final recipe = savedRecipesProvider.savedRecipes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewResep(docId: recipe['docId']),
                      ),
                    );
                  },
                  child: RecipeCard(recipe: recipe),
                );
              },
              itemCount: savedRecipesProvider.savedRecipes.length,
            ),
          );
        },
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe['imageUrl'] ?? 'https://via.placeholder.com/150';
    final title = recipe['title'] ?? 'No title';
    final publisherName = recipe['publisherName'] ?? 'Unknown';
    final rating = recipe['rating']?.toString() ?? 'N/A';
    final docId = recipe['docId'];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
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
                      publisherName,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Consumer<SavedRecipesProvider>(
                      builder: (context, savedRecipesProvider, child) {
                        final isSaved = savedRecipesProvider.isSaved(docId);
                        return IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            savedRecipesProvider.toggleRecipe(recipe);
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16.0,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      rating,
                      style: TextStyle(
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
