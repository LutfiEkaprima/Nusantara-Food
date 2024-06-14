import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class TambahResep extends StatefulWidget {
  @override
  _TambahResepState createState() => _TambahResepState();
}

class _TambahResepState extends State<TambahResep> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _stepControllers = [];
  List<TextEditingController> _toolControllers = [];
  List<TextEditingController> _categoryControllers = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _portionController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  List<String?> _stepImages = [];
  XFile? _image;
  bool _isFood = false;
  bool _isDrink = false;

  @override
  void initState() {
    super.initState();
    _ingredientControllers.add(TextEditingController());
    _stepControllers.add(TextEditingController());
    _toolControllers.add(TextEditingController());
    _categoryControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _ingredientControllers.forEach((controller) => controller.dispose());
    _stepControllers.forEach((controller) => controller.dispose());
    _toolControllers.forEach((controller) => controller.dispose());
    _categoryControllers.forEach((controller) => controller.dispose());
    _titleController.dispose();
    _portionController.dispose();
    _costController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveResep(String status) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToStorage(_image!);
      }

      final docRef = await _firestore.collection('resep').add({
        'userId': user.uid,
        'title': _titleController.text,
        'portion': _portionController.text,
        'cost': _costController.text,
        'time': _timeController.text,
        'isFood': _isFood,
        'isDrink': _isDrink,
        'ingredients': _ingredientControllers.map((e) => e.text).toList(),
        'steps': _stepControllers.map((e) => e.text).toList(),
        'tools': _toolControllers.map((e) => e.text).toList(),
        'categories': _categoryControllers.map((e) => e.text).toList(),
        'stepImages': _stepImages,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep berhasil disimpan sebagai $status')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan resep: $e')),
      );
    }
  }

  Future<String> _uploadImageToStorage(XFile image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('recipe_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(File(image.path));
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
      );
    }
  }

  Future<void> _pickStepImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageUrl = await _uploadImageToStorage(pickedFile);
      setState(() {
        if (index < _stepImages.length) {
          _stepImages[index] = imageUrl;
        } else {
          _stepImages.add(imageUrl);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: Text('TAMBAHKAN RESEP MAKANAN'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Judul Resep'),
            _buildTextField('Tulis judul resepmu secara ringkas',
                controller: _titleController),
            SizedBox(height: 16.0),
            _buildSectionTitle('Foto Resep'),
            _buildImagePicker(),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                    child: _buildTextField('Porsi Resep',
                        controller: _portionController)),
                SizedBox(width: 16.0),
                Expanded(
                    child: _buildTextField('Estimasi Pengeluaran',
                        controller: _costController)),
              ],
            ),
            SizedBox(height: 16.0),
            _buildTextField('Waktu Memasak', controller: _timeController),
            SizedBox(height: 16.0),
            _buildSectionTitle('Jenis Makanan'),
            _buildFoodTypeSelection(),
            SizedBox(height: 16.0),
            _buildSectionTitle('Bahan Utama Resep'),
            _buildReorderableIngredientFields(),
            _buildAddButton('Tambah Bahan Utama', _addIngredientField),
            SizedBox(height: 16.0),
            _buildSectionTitle('Alat & Perlengkapan Memasak'),
            _buildReorderableToolsFields(),
            _buildAddButton('Tambah Alat & Perlengkapan', _addToolField),
            SizedBox(height: 16.0),
            _buildSectionTitle('Langkah - langkah memasak'),
            _buildReorderableStepsFields(),
            _buildAddButton('Tambah Langkah Memasak', _addStepField),
            SizedBox(height: 16.0),
            _buildSectionTitle('Kategori Resep'),
            _buildReorderableCategoryFields(),
            _buildAddButton('Tambah Kategori', _addCategoryField),
            SizedBox(height: 30.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSaveButton('Simpan', () => _saveResep('draft')),
                  SizedBox(width: 16.0),
                  _buildUploadButton('Upload', () => _saveResep('ditinjau')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _image == null
            ? Icon(Icons.add_a_photo, size: 50.0)
            : Image.file(File(_image!.path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFoodTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: Text('Makanan'),
            value: _isFood,
            onChanged: (bool? value) {
              setState(() {
                _isFood = value ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            title: Text('Minuman'),
            value: _isDrink,
            onChanged: (bool? value) {
              setState(() {
                _isDrink = value ?? false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSaveButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }

  Widget _buildUploadButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }

  Widget _buildReorderableIngredientFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = _ingredientControllers.removeAt(oldIndex);
        _ingredientControllers.insert(newIndex, item);
      },
      children: List.generate(_ingredientControllers.length, (index) {
        return ListTile(
          key: Key('$index'),
          title: TextField(
            controller: _ingredientControllers[index],
            decoration: InputDecoration(
              hintText: 'Bahan Utama ${index + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeIngredientField(index),
              ),
              Icon(Icons.drag_handle),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReorderableStepsFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = _stepControllers.removeAt(oldIndex);
        _stepControllers.insert(newIndex, item);

        final image = _stepImages.removeAt(oldIndex);
        _stepImages.insert(newIndex, image);
      },
      children: List.generate(_stepControllers.length, (index) {
        return ListTile(
          key: Key('$index'),
          title: TextField(
            controller: _stepControllers[index],
            decoration: InputDecoration(
              hintText: 'Langkah ${index + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () => _pickStepImage(index),
              ),
              if (_stepImages.length > index && _stepImages[index] != null)
                Image.network(
                  _stepImages[index]!,
                  width: 50,
                  height: 50,
                ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeStepField(index),
              ),
              Icon(Icons.drag_handle),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReorderableToolsFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = _toolControllers.removeAt(oldIndex);
        _toolControllers.insert(newIndex, item);
      },
      children: List.generate(_toolControllers.length, (index) {
        return ListTile(
          key: Key('$index'),
          title: TextField(
            controller: _toolControllers[index],
            decoration: InputDecoration(
              hintText: 'Alat ${index + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeToolField(index),
              ),
              Icon(Icons.drag_handle),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReorderableCategoryFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = _categoryControllers.removeAt(oldIndex);
        _categoryControllers.insert(newIndex, item);
      },
      children: List.generate(_categoryControllers.length, (index) {
        return ListTile(
          key: Key('$index'),
          title: TextField(
            controller: _categoryControllers[index],
            decoration: InputDecoration(
              hintText: 'Kategori ${index + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeCategoryField(index),
              ),
              Icon(Icons.drag_handle),
            ],
          ),
        );
      }),
    );
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepImages.add(null);
    });
  }

  void _removeStepField(int index) {
    setState(() {
      _stepControllers.removeAt(index);
      _stepImages.removeAt(index);
    });
  }

  void _addToolField() {
    setState(() {
      _toolControllers.add(TextEditingController());
    });
  }

  void _removeToolField(int index) {
    setState(() {
      _toolControllers.removeAt(index);
    });
  }

  void _addCategoryField() {
    setState(() {
      _categoryControllers.add(TextEditingController());
    });
  }

  void _removeCategoryField(int index) {
    setState(() {
      _categoryControllers.removeAt(index);
    });
  }
}
