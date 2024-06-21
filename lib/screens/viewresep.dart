import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_food/utils.dart';

class ViewResep extends StatefulWidget {
  final String docId;

  const ViewResep({super.key, required this.docId});

  @override
  _ViewResepState createState() => _ViewResepState();
}

class _ViewResepState extends State<ViewResep> {
  final TextEditingController commentController = TextEditingController();
  double userRating = 0.0;
  Map<String, dynamic>? _userData;

  DocumentSnapshot? resepData;
  List<dynamic> comments = [];
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final data = await fetchUserData();
    setState(() {
      _userData = data;
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

  Future<void> fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.docId)
          .get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      QuerySnapshot ratingsSnapshot =
          await doc.reference.collection('ratings').get();
      Map<String, dynamic> ratings = {
        for (var doc in ratingsSnapshot.docs) doc.id: doc.data(),
      };

      setState(() {
        resepData = doc;
        comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        userRating = ratings.containsKey(FirebaseAuth.instance.currentUser?.uid)
            ? (ratings[FirebaseAuth.instance.currentUser!.uid]
                    as Map<String, dynamic>)['rating']
                .toDouble()
            : 0.0;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && commentController.text.isNotEmpty) {
      // Create the comment with a temporary timestamp
      final comment = {
        'text': commentController.text,
        'userId': user.uid,
        'userName': _userData?['name'] ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(), // Correct usage here
      };

      // Add the comment to Firestore
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('resep').doc(widget.docId);
      await docRef.update({
        'comments': FieldValue.arrayUnion([comment]),
      });

      // Clear the comment controller and refresh the state
      setState(() {
        commentController.clear();
        fetchData();
      });
    }
  }

  Future<void> submitRating(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('resep').doc(widget.docId);
      CollectionReference ratingsRef = docRef.collection('ratings');

      DocumentSnapshot userRatingSnapshot =
          await ratingsRef.doc(user.uid).get();

      if (!userRatingSnapshot.exists) {
        await ratingsRef.doc(user.uid).set({'rating': rating});

        // Recalculate the overall rating
        QuerySnapshot ratingsSnapshot = await ratingsRef.get();
        double totalRating = ratingsSnapshot.docs.fold(0.0,
            (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['rating']);
        double overallRating = totalRating / ratingsSnapshot.size;

        await docRef.update({'overallRating': overallRating});

        setState(() {
          userRating = rating;
        });
      } else {
        print('User has already rated');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resepData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Map<String, dynamic> data = resepData!.data() as Map<String, dynamic>;
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: Text(
          data['title'],
          style: textStyle(20, Colors.black, FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  data['imageUrl'] ??
                      'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82',
                  height: 500,
                  width: 500,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(data['title'],
                  style: textStyle(20, Colors.black, FontWeight.bold)),
              const SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 4.0),
                        Text('${data['time']} Menit'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 4.0),
                        Text('Porsi untuk ${data['portion']} orang'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.attach_money),
                        SizedBox(width: 4.0),
                        Text('Rp. ${data['cost']}'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.verified),
                        SizedBox(width: 4.0),
                        Text(data['recipeType'] ?? 'null'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        _userData?['fotoProfil'] ??
                            'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82',
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['publisherName'] ?? 'Anonymous',
                          style: textStyle(16, Colors.black, FontWeight.w600),
                        ),
                        SizedBox(height: 4.0),
                        Text('Tanggal Upload: $formattedDate'),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star_border),
                            SizedBox(width: 8.0),
                            Text('${averageRating.toStringAsFixed(1)}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Informasi Resep',
                style: textStyle(20, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Bahan Memasak',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(data['ingredients'].join('\n')),
              const SizedBox(height: 16.0),
              Text(
                'Peralatan Memasak',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(data['tools'].join('\n')),
              const SizedBox(height: 16.0),
              Text(
                'Cara Memasak Resep',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(data['steps'].length, (index) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 20.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: (data['stepImages'] != null &&
                                    data['stepImages'].length > index &&
                                    data['stepImages'][index] != null)
                                ? Image.network(data['stepImages'][index])
                                : null,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Step ${index + 1}',
                            style: textStyle(16, Colors.black, FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Text(data['steps'][index]),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Kategori Resep',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(data['categories'].length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(data['categories'][index]),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Komentar',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Column(
                children: comments.map((comment) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/150'),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(comment['text'])),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: submitComment,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Beri Rating',
                style: textStyle(16, Colors.black, FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < userRating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      submitRating(index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
