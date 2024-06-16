import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewResep extends StatefulWidget {
  final String docId;

  const ViewResep({super.key, required this.docId});

  @override
  _ViewResepState createState() => _ViewResepState();
}

class _ViewResepState extends State<ViewResep> {
  final List<String> comments = [];
  final TextEditingController commentController = TextEditingController();
  double userRating = 0.0;

  DocumentSnapshot? resepData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('resep').doc(widget.docId).get();
      setState(() {
        resepData = doc;
      });
    } catch (e) {
      print('Error fetching data: $e');
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: Text(data['title']),
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
                  data['imageUrl'] ?? 'https://via.placeholder.com/150',
                  height: 500,
                  width: 500,
                  fit:  BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                data['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                        Text(data['isFood'] ? 'Makanan' : 'Minuman'),
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
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual avatar URL
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['publisherName'] ?? 'Anonymous',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text('Tanggal Upload: ${data['createdAt'].toDate()}'),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star, color: Colors.yellow),
                            Icon(Icons.star_border),
                            SizedBox(width: 8.0),
                            Text('4.0'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Informasi Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Bahan Memasak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(data['ingredients'].join('\n')),
              const SizedBox(height: 16.0),
              const Text(
                'Peralatan Memasak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(data['tools'].join('\n')),
              const SizedBox(height: 16.0),
              const Text(
                'Cara Memasak Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                            child: data['stepImages'] != null && data['stepImages'].length > index
                                ? Image.network(data['stepImages'][index])
                                : null,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Step ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
              const Text(
                'Kategori Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder avatar image
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(comment)),
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
                        onPressed: () {
                          setState(() {
                            if (commentController.text.isNotEmpty) {
                              comments.add(commentController.text);
                              commentController.clear();
                            }
                          });
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Beri Rating',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                      setState(() {
                        userRating = index + 1.0;
                      });
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
