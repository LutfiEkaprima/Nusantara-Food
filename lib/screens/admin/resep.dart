import 'package:flutter/material.dart';
import 'package:nusantara_food/providers/save_resep_provider.dart';
import 'package:nusantara_food/screens/viewresep.dart';
import 'package:provider/provider.dart';
import 'package:nusantara_food/utils.dart';

class ResepScreenadm extends StatelessWidget {
  const ResepScreenadm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Resep Yang Disimpan', style: textStyle( 20 ,Colors.black, FontWeight.bold),),
      ),
      body: Consumer<SavedRecipesProvider>(
        builder: (context, savedRecipesProvider, child) {
          if (savedRecipesProvider.savedRecipes.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada resep yang disimpan',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.8,
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

    final truncatedPublisherName = publisherName.length > 10
        ? publisherName.substring(0, 15) + '...'
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
