import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String productName = '';
  String price = '';
  String description = '';
  File? _imageFile;
  bool _isUploading = false;
  bool _isPickingImage = false; // Guard flag for image picker

  // Pick image from gallery safely
  Future<void> pickImage() async {
    if (_isPickingImage) return; // Prevent multiple pickers opening

    _isPickingImage = true;
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Image picking failed: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  // Upload image to Cloudinary and return URL
  Future<String> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'deh3bslzf'; // Replace with your Cloudinary cloud name
    const uploadPreset = 'flutter_unsigned'; // Replace with your unsigned upload preset

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      throw Exception('Image upload failed with status ${response.statusCode}');
    }
  }

  // Save product to Firestore
  Future<void> addProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isUploading = true);

      String imageUrl = '';

      try {
        if (_imageFile != null) {
          imageUrl = await uploadImageToCloudinary(_imageFile!);
        }

        await FirebaseFirestore.instance.collection('products').add({
          'name': productName,
          'name_lowercase': productName.toLowerCase(),
          'price': double.tryParse(price),
          'description': description,
          'imageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      onSaved: (value) => productName = value!,
                      validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => price = value!,
                      validator: (value) => value == null || value.isEmpty ? 'Enter a price' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (value) => description = value!,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                    ),
                    const SizedBox(height: 10),
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 150)
                        : const Text("No image selected"),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: addProduct,
                      child: const Text('Add Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
