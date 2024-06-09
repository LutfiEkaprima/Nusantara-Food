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
        title: Text('Caramel Pudding'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              SizedBox(height: 16.0),
              Text(
                'Caramel Pudding',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              SingleChildScrollView(
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
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.all(8.0),
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
              SizedBox(height: 16.0),
              Text(
                'Informasi Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Bahan Memasak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text('- 1 bungkus tepung custard instant\n- 1 liter susu full cream cair\n- 200gr gula pasir\n- 1 sdm air jeruk nipis'),
              SizedBox(height: 16.0),
              Text(
                'Peralatan Memasak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text('- Sendok Sayur\n- Cetakan Puding\n- Sendok\n- Panci\n- Panci Besar\n- Panci Kecil'),
              SizedBox(height: 16.0),
              Text(
                'Cara Memasak Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 300,
                      margin: EdgeInsets.only(right: 20.0),
                      padding: EdgeInsets.all(8.0),
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
                          SizedBox(height: 8.0),
                          Text(
                            'Step ${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text('Panaskan gula dalam panci dengan 1 sdm jeruk nipis dan air. Jangan diaduk, biarkan hingga terkaramelisasi. Beri sedikit air di bagian pinggir panci agar tidak gosong. Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.Beri sedikit air di bagian pinggir panci agar tidak gosong.'),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Kategori Resep',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categories.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(categories[index]),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Column(
                children: comments.map((comment) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder avatar image
                        ),
                        SizedBox(width: 8.0),
                        Expanded(child: Text(comment)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(8.0),
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
                    SizedBox(height: 8.0),
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
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Beri Rating',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
