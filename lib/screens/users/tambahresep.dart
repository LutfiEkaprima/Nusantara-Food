import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class TambahResep extends StatefulWidget {
  final DocumentSnapshot? draft;

  const TambahResep({super.key, this.draft});

  @override
  _TambahResepState createState() => _TambahResepState();
}

class _TambahResepState extends State<TambahResep> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _stepControllers = [];
  List<TextEditingController> _toolControllers = [];
  List<TextEditingController> _categoryControllers = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<String?> _stepImages = [];
  XFile? _image;
  bool _isFood = false;
  bool _isDrink = false;

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      _loadDraftData(widget.draft!);
    } else {
      _ingredientControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
      _toolControllers.add(TextEditingController());
      _categoryControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    for (var controller in _toolControllers) {
      controller.dispose();
    }
    for (var controller in _categoryControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _portionController.dispose();
    _costController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadDraftData(DocumentSnapshot draft) async {
    setState(() {
      _titleController.text = draft['title'];
      _portionController.text = draft['portion'];
      _costController.text = draft['cost'];
      _timeController.text = draft['time'];
      _isFood = draft['isFood'];
      _isDrink = draft['isDrink'];
      _ingredientControllers = (draft['ingredients'] as List<dynamic>).map((e) => TextEditingController(text: e as String)).toList();
      _stepControllers = (draft['steps'] as List<dynamic>).map((e) => TextEditingController(text: e as String)).toList();
      _toolControllers = (draft['tools'] as List<dynamic>).map((e) => TextEditingController(text: e as String)).toList();
      _categoryControllers = (draft['categories'] as List<dynamic>).map((e) => TextEditingController(text: e as String)).toList();
      _stepImages = List<String?>.from(draft['stepImages']);
      if (draft['imageUrl'] != null) {
        _image = XFile(draft['imageUrl']);
      }
    });
  }

  Future<void> _saveResep(String status) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToStorage(_image!);
      }

      final docData = {
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
      };

      if (widget.draft != null) {
        await widget.draft!.reference.update(docData);
      } else {
        await _firestore.collection('resep').add(docData);
      }

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
        const SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
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
        const SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFED),
        title: Text(widget.draft != null ? 'Edit Resep' : 'Tambah Resep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Judul Resep'),
              _buildTextField(
                'Tulis judul resepmu secara ringkas',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul resep tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Foto Resep'),
              _buildImagePicker(),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Porsi Resep',
                      controller: _portionController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Porsi resep tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Porsi resep harus berupa angka';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField(
                      'Estimasi Pengeluaran',
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Estimasi pengeluaran tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Estimasi pengeluaran harus berupa angka';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                'Waktu Memasak',
                controller: _timeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu memasak tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Waktu memasak harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Jenis Makanan'),
              _buildFoodTypeSelection(),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Bahan Utama'),
              _buildReorderableIngredientFields(),
              const SizedBox(height: 8.0),
              _buildAddButton('Tambah Bahan', _addIngredientField),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Alat & Perlengkapan'),
              _buildReorderableToolsFields(),
              const SizedBox(height: 8.0),
              _buildAddButton('Tambah Alat', _addToolField),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Langkah Memasak'),
              _buildReorderableStepsFields(),
              const SizedBox(height: 8.0),
              _buildAddButton('Tambah Langkah', _addStepField),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Kategori Resep'),
              _buildReorderableCategoryFields(),
              const SizedBox(height: 8.0),
              _buildAddButton('Tambah Kategori', _addCategoryField),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSaveButton('Simpan Draft', () => _saveResep('draft')),
                  _buildUploadButton('Unggah', () => _saveResep('ditinjau')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String hintText, {TextEditingController? controller, TextInputType? keyboardType, FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      validator: validator,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: _image == null
            ? const Icon(Icons.add_a_photo, size: 50)
            : Image.file(File(_image!.path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFoodTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Makanan'),
            value: true,
            groupValue: _isFood,
            onChanged: (newValue) {
              setState(() {
                _isFood = newValue ?? false;
                _isDrink = !newValue!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Minuman'),
            value: true,
            groupValue: _isDrink,
            onChanged: (newValue) {
              setState(() {
                _isDrink = newValue ?? false;
                _isFood = !newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableIngredientFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final controller = _ingredientControllers.removeAt(oldIndex);
          _ingredientControllers.insert(newIndex, controller);
        });
      },
      children: _ingredientControllers
          .asMap()
          .map((i, controller) => MapEntry(
                i,
                ListTile(
                  key: ValueKey(i),
                  title: Row(
                    children: [
                      Expanded(child: _buildTextField('Masukkan Bahan Utama', controller: controller)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeIngredientField(i),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildReorderableToolsFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final controller = _toolControllers.removeAt(oldIndex);
          _toolControllers.insert(newIndex, controller);
        });
      },
      children: _toolControllers
          .asMap()
          .map((i, controller) => MapEntry(
                i,
                ListTile(
                  key: ValueKey(i),
                  title: Row(
                    children: [
                      Expanded(child: _buildTextField('Masukkan Alat & Perlengkapan', controller: controller)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeToolField(i),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildReorderableStepsFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final controller = _stepControllers.removeAt(oldIndex);
          _stepControllers.insert(newIndex, controller);
          final stepImage = _stepImages.removeAt(oldIndex);
          _stepImages.insert(newIndex, stepImage);
        });
      },
      children: _stepControllers
          .asMap()
          .map((i, controller) => MapEntry(
                i,
                ListTile(
                  key: ValueKey(i),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Masukkan Langkah Memasak', controller: controller)),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeStepField(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () => _pickStepImage(i),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: _stepImages.length > i && _stepImages[i] != null
                              ? Image.network(_stepImages[i]!, fit: BoxFit.cover)
                              : const Icon(Icons.add_a_photo, size: 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildReorderableCategoryFields() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final controller = _categoryControllers.removeAt(oldIndex);
          _categoryControllers.insert(newIndex, controller);
        });
      },
      children: _categoryControllers
          .asMap()
          .map((i, controller) => MapEntry(
                i,
                ListTile(
                  key: ValueKey(i),
                  title: Row(
                    children: [
                      Expanded(child: _buildTextField('Masukkan Kategori Resep', controller: controller)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeCategoryField(i),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(label),
    );
  }

  Widget _buildSaveButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: onPressed,
      child: Text(label),
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
