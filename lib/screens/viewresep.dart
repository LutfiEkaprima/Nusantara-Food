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

      QuerySnapshot commentsSnapshot =
          await doc.reference.collection('comments').orderBy('timestamp').get();
      List<Map<String, dynamic>> commentsList = commentsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      QuerySnapshot ratingsSnapshot =
          await doc.reference.collection('ratings').get();
      List<Map<String, dynamic>> ratingsList = ratingsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      double totalRating = 0.0;
      int ratingCount = ratingsList.length;
      double initialUserRating = 0.0;

      for (var rating in ratingsList) {
        if (rating.containsKey('rating')) {
          totalRating += rating['rating'];
        }
        if (rating['userId'] == FirebaseAuth.instance.currentUser?.uid) {
          initialUserRating = rating['rating'].toDouble();
        }
      }

      double overallRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

      setState(() {
        resepData = doc;
        comments = commentsList;
        userRating = initialUserRating;
        averageRating = overallRating;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && commentController.text.isNotEmpty) {
      final comment = {
        'text': commentController.text,
        'userId': user.uid,
        'userName': _userData?['nama'] ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef =
          FirebaseFirestore.instance.collection('resep').doc(widget.docId);

      try {
        CollectionReference commentsRef = docRef.collection('comments');
        DocumentReference newCommentRef = await commentsRef.add(comment);
        DocumentSnapshot newCommentSnapshot = await newCommentRef.get();

        setState(() {
          comments.add({
            'text': commentController.text,
            'userId': user.uid,
            'userName': _userData?['nama'] ?? 'Anonymous',
            'timestamp': Timestamp.now(),
          });
          commentController.clear();
          print(_userData?['nama']);
        });
      } catch (e) {
        print('Error submitting comment: $e');
      }
    }
  }

  Future<void> submitRating(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('resep').doc(widget.docId);

      try {
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> ratings = data['ratings'] ?? {};

        ratings[user.uid] = {'rating': rating};

        double totalRating = 0.0;
        int ratingCount = 0;

        ratings.forEach((key, value) {
          if (value is Map && value.containsKey('rating')) {
            totalRating += value['rating'];
            ratingCount++;
          }
        });

        double overallRating =
            ratingCount > 0 ? totalRating / ratingCount : 0.0;

        await docRef.update({
          'ratings': ratings,
          'overallRating': overallRating,
        });

        setState(() {
          userRating = rating;
          averageRating = overallRating;
        });
      } catch (e) {
        print('Error submitting rating: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resepData == null) {
      return const Scaffold(
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
                        const Icon(Icons.access_time),
                        const SizedBox(width: 4.0),
                        Text('${data['time']} Menit'),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(width: 4.0),
                        Text('Porsi untuk ${data['portion']} orang'),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.attach_money),
                        const SizedBox(width: 4.0),
                        Text('Rp. ${data['cost']}'),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.verified),
                        const SizedBox(width: 4.0),
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
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['publisherName'] ?? 'Anonymous',
                          style: textStyle(16, Colors.black, FontWeight.w600),
                        ),
                        const SizedBox(height: 4.0),
                        Text('Tanggal Upload: $formattedDate'),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < data['overallRating']
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.yellow,
                              );
                            }),
                            const SizedBox(width: 8.0),
                            Text(
                                '${data['overallRating'].toStringAsFixed(1)}'),
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
              Text('Komentar:', style: textStyle(18, Colors.black, FontWeight.bold)),
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
                        labelText: 'Tulis komentar...',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: submitComment,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      children: List.generate(
                        comments.length,
                        (index) {
                          Map<String, dynamic> comment = comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    'https://firebasestorage.googleapis.com/v0/b/nusatara-food.appspot.com/o/default_image%2FIcon.png?alt=media&token=b74c7a3e-950f-402a-9deb-07a0d062be82',
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['userName'],
                                        style: textStyle(14, Colors.black, FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(comment['text']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
