import 'package:flutter/material.dart';

class SavedRecipesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _savedRecipes = [];

  List<Map<String, dynamic>> get savedRecipes => _savedRecipes;

  void addRecipe(Map<String, dynamic> recipe) {
    _savedRecipes.add(recipe);
    notifyListeners();
  }

  void removeRecipe(String docId) {
    _savedRecipes.removeWhere((recipe) => recipe['docId'] == docId);
    notifyListeners();
  }

  bool isSaved(String docId) {
    return _savedRecipes.any((recipe) => recipe['docId'] == docId);
  }

  void toggleRecipe(Map<String, dynamic> recipe) {
    if (isSaved(recipe['docId'])) {
      removeRecipe(recipe['docId']);
    } else {
      addRecipe(recipe);
    }
  }
}
