import 'package:flutter/material.dart';

class ViewResep extends StatefulWidget {
  @override
  _ViewResepState createState() => _ViewResepState();
}

class _ViewResepState extends State<ViewResep> {
  final List<String> comments = [];
  final TextEditingController commentController = TextEditingController();
  double userRating = 0.0;
  final List<String> categories = ['Makanan Penutup', 'Cemilan Manis', 'Pudding', 'Dessert', 'Snack', 'Sweet Treats'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: const Text('Caramel Pudding'),
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
                  'https://via.placeholder.com/300', // Replace with your image URL
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Caramel Pudding',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 4.0),
                        Text('40 Menit'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 4.0),
                        Text('Porsi untuk 2 orang'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.attach_money),
                        SizedBox(width: 4.0),
                        Text('Rp. 50.000'),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Row(
                      children: [
                        Icon(Icons.verified),
                        SizedBox(width: 4.0),
                        Text('Halal'),
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
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual avatar URL
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daffa Dandana',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text('Tanggal Upload: 01/01/2024'),
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
              const Text('- 1 bungkus tepung custard instant\n- 1 liter susu full cream cair\n- 200gr gula pasir\n- 1 sdm air jeruk nipis'),
              const SizedBox(height: 16.0),
              const Text(
                'Peralatan Memasak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              const Text('- Sendok Sayur\n- Cetakan Puding\n- Sendok\n- Panci\n- Panci Besar\n- Panci Kecil'),
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
                  children: List.generate(5, (index) {
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
                          const Text('Panaskan gula dalam panci dengan 1 sdm jeruk nipis dan air. Jangan diaduk, biarkan hingga terkaramelisasi. Beri sedikit air di bagian pinggir panci agar tidak gosong. Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.'),
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
                  children: List.generate(categories.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(categories[index]),
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
