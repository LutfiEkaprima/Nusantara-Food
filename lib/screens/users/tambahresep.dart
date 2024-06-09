import 'package:flutter/material.dart';

class TambahResep extends StatelessWidget {
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
            _buildTextField('Tulis judul resepmu secara ringkas'),
            SizedBox(height: 16.0),
            _buildSectionTitle('Foto Resep'),
            _buildImagePicker(),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(child: _buildTextField('Porsi Resep')),
                SizedBox(width: 16.0),
                Expanded(child: _buildTextField('Estimasi Pengeluaran')),
              ],
            ),
            SizedBox(height: 16.0),
            _buildTextField('Waktu Memasak'),
            SizedBox(height: 16.0),
            _buildSectionTitle('Jenis Makanan'),
            _buildFoodTypeSelection(),
            SizedBox(height: 16.0),
            _buildSectionTitle('Bahan Utama Resep'),
            _buildIngredientFields(),
            _buildAddButton('Tambah Bahan Utama'),
            SizedBox(height: 16.0),
            _buildSectionTitle('Langkah - langkah memasak'),
            _buildStepsFields(),
            _buildAddButton('Tambah Langkah Memasak'),
            SizedBox(height: 16.0),
            _buildSectionTitle('Kategori Resep Masakanmu'),
            _buildCategorySelection(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSaveButton('Simpan'),
                _buildUploadButton('Upload'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 100.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Center(
        child: Icon(Icons.image, size: 50.0),
      ),
    );
  }

  Widget _buildFoodTypeSelection() {
    return Row(
      children: [
        Expanded(child: _buildCheckbox('Makanan')),
        Expanded(child: _buildCheckbox('Minuman')),
      ],
    );
  }

  Widget _buildCheckbox(String title) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (value) {}),
        Text(title),
      ],
    );
  }

  Widget _buildIngredientFields() {
    return Column(
      children: List.generate(3, (index) => _buildTextField('')),
    );
  }

  Widget _buildStepsFields() {
    return Column(
      children: List.generate(5, (index) => _buildStepField(index + 1)),
    );
  }

  Widget _buildStepField(int stepNumber) {
    return Row(
      children: [
        Text('$stepNumber.'),
        SizedBox(width: 8.0),
        Expanded(child: _buildTextField('')),
        SizedBox(width: 8.0),
        Icon(Icons.image, size: 40.0),
      ],
    );
  }

  Widget _buildAddButton(String title) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        child: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(6, (index) => _buildCategoryChip()),
    );
  }

  Widget _buildCategoryChip() {
    return FilterChip(
      label: Text('Kategori'),
      selected: false,
      onSelected: (value) {},
    );
  }

  Widget _buildSaveButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: Size(150, 50),
      ),
    );
  }

  Widget _buildUploadButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        minimumSize: Size(150, 50),
      ),
    );
  }
}
