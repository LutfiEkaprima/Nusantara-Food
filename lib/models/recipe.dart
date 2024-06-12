import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String id;
  String userId;
  String title;
  String portion;
  String cost;
  String time;
  bool isFood;
  bool isDrink;
  List<String> ingredients;
  List<String> steps;
  List<String> tools;
  List<String> categories;
  String status;
  Timestamp createdAt; // Use Timestamp
  String? imageUrl;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.portion,
    required this.cost,
    required this.time,
    required this.isFood,
    required this.isDrink,
    required this.ingredients,
    required this.steps,
    required this.tools,
    required this.categories,
    required this.status,
    required this.createdAt,
    this.imageUrl,
  });

  factory Recipe.fromMap(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      userId: data['userId'],
      title: data['title'],
      portion: data['portion'],
      cost: data['cost'],
      time: data['time'],
      isFood: data['isFood'],
      isDrink: data['isDrink'],
      ingredients: List<String>.from(data['ingredients']),
      steps: List<String>.from(data['steps']),
      tools: List<String>.from(data['tools']),
      categories: List<String>.from(data['categories']),
      status: data['status'],
      createdAt: data['createdAt'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'portion': portion,
      'cost': cost,
      'time': time,
      'isFood': isFood,
      'isDrink': isDrink,
      'ingredients': ingredients,
      'steps': steps,
      'tools': tools,
      'categories': categories,
      'status': status,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
    };
  }
}
