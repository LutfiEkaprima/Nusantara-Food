import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
  String? _imageUrl;
  String _recipeType = 'Makanan';

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      _loadDraftData(widget.draft!);
    } else {
      _addNewItem(_ingredientControllers);
      _addNewItem(_stepControllers);
      _addNewItem(_toolControllers);
      _addNewItem(_categoryControllers);
      _stepImages.add(null);
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
      _recipeType = draft['recipeType'];
      _ingredientControllers = (draft['ingredients'] as List<dynamic>)
          .map((e) => TextEditingController(text: e as String))
          .toList();
      _stepControllers = (draft['steps'] as List<dynamic>)
          .map((e) => TextEditingController(text: e as String))
          .toList();
      _toolControllers = (draft['tools'] as List<dynamic>)
          .map((e) => TextEditingController(text: e as String))
          .toList();
      _categoryControllers = (draft['categories'] as List<dynamic>)
          .map((e) => TextEditingController(text: e as String))
          .toList();
      _stepImages = List<String?>.from(draft['stepImages']);
      if (draft['imageUrl'] != null) {
        _imageUrl = draft['imageUrl'];
      }

      if (draft['createdAt'] != null) {
        Timestamp timestamp = draft['createdAt'] as Timestamp;
        DateTime createdAt = timestamp.toDate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);
      }
    });
  }

  Future<String?> getUserName(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc['nama'] != null) {
      return userDoc['nama'];
    }
    return null;
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

      String? publisherName = await getUserName(user.uid);
      if (publisherName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama pengguna tidak ditemukan.')),
        );
        return;
      }


      String? imageUrl = _imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToStorage(_image!);
        _imageUrl = null;
      }

      final docData = {
        'userId': user.uid,
        'publisherName': publisherName,
        'title': _titleController.text,
        'portion': _portionController.text,
        'cost': _costController.text,
        'time': _timeController.text,
        'recipeType': _recipeType,
        'ingredients': _ingredientControllers.map((e) => e.text).toList(),
        'steps': _stepControllers.map((e) => e.text).toList(),
        'tools': _toolControllers.map((e) => e.text).toList(),
        'categories': _categoryControllers.map((e) => e.text).toList(),
        'stepImages': _stepImages,
        'status': status,
        'createdAt': FieldValue
            .serverTimestamp(),
        'imageUrl': imageUrl,
        'overallRating': 0.0,
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

  void _addNewItem(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeItem(List<TextEditingController> controllers, int index) {
    setState(() {
      if (controllers.length > 1) {
        controllers.removeAt(index);
      } else {
        controllers[0].clear();
      }
    });
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
                'Waktu Memasak (menit)',
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
              _buildSectionTitle('Jenis Resep'),
              Row(
                children: [
                  _buildRadioButton('Makanan', _recipeType, (value) {
                    setState(() {
                      _recipeType = value!;
                    });
                  }),
                  const SizedBox(width: 16.0),
                  _buildRadioButton('Minuman', _recipeType, (value) {
                    setState(() {
                      _recipeType = value!;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Bahan-bahan'),
              _buildDynamicTextField(_ingredientControllers, 'Bahan'),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Peralatan Masak'),
              _buildDynamicTextField(_toolControllers, 'Peralatan'),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Langkah-langkah'),
              _buildDynamicStepField(),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Kategori Resep'),
              _buildDynamicTextField(_categoryControllers, 'Kategori'),
              const SizedBox(height: 30.0),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: const TextStyle(fontSize: 13),
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDynamicTextField(
      List<TextEditingController> controllers, String hintText) {
    return Column(
      children: List.generate(controllers.length, (index) {
        return Row(
          children: [
            Expanded(
              child: _buildTextField(
                '$hintText ${index + 1}',
                controller: controllers[index],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '$hintText tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            _buildAddRemoveButton(controllers, index),
          ],
        );
      }),
    );
  }

  Widget _buildAddRemoveButton(
      List<TextEditingController> controllers, int index) {
    return IconButton(
      icon: Icon(
        index == controllers.length - 1 ? Icons.add : Icons.remove,
        color: Colors.blue,
      ),
      onPressed: () {
        setState(() {
          if (index == controllers.length - 1) {
            controllers.add(TextEditingController());
            if (controllers == _stepControllers) {
              _stepImages.add(null);
            }
          } else {
            controllers.removeAt(index);
            if (controllers == _stepControllers) {
              _stepImages.removeAt(index);
            }
          }
        });
      },
    );
  }

  Widget _buildDynamicStepField() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final TextEditingController step =
              _stepControllers.removeAt(oldIndex);
          final String? image = _stepImages.removeAt(oldIndex);
          _stepControllers.insert(newIndex, step);
          _stepImages.insert(newIndex, image);
        });
      },
      children: List.generate(_stepControllers.length, (index) {
        return Column(
          key: ValueKey('step_$index'),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Langkah ${index + 1}',
                    controller: _stepControllers[index],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Langkah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _buildAddRemoveButton(_stepControllers, index),
              ],
            ),
            const SizedBox(height: 8),
            _buildStepImagePicker(index),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  Widget _buildStepImagePicker(int index) {
    return Row(
      children: [
        Expanded(
          child: _stepImages[index] != null
              ? Image.network(_stepImages[index]!, height: 150)
              : const Text('Belum ada gambar untuk langkah ini.',
                  style: TextStyle(fontSize: 12)),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.blue),
          onPressed: () => _pickStepImage(index),
        ),
      ],
    );
  }

  Widget _buildRadioButton(
      String title, String groupValue, void Function(String?)? onChanged) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(title),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => _saveResep('ditinjau'),
          child: const Text(
            'Upload Resep',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => _saveResep('draft'),
          child: const Text(
            'Simpan Resep',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        _imageUrl != null
            ? Image.network(_imageUrl!)
            : _image != null
                ? Image.file(File(_image!.path))
                : const Text('Belum ada gambar yang dipilih.'),
        TextButton(
          onPressed: _pickImage,
          child: const Text(
            'Pilih Gambar',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
