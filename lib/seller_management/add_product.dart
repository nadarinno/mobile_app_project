import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard_for_seller.dart';
import 'utils.dart';

class AddProductDialog extends StatefulWidget {
  final VoidCallback updateTotals;
  final BuildContext parentContext;

  AddProductDialog({required this.updateTotals, required this.parentContext});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  List<String> selectedColors = [];
  List<String> availableColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow', 'Purple', 'Orange', 'Pink'];
  File? _imageFile;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addColor() {
    final color = _colorController.text.trim();
    if (color.isNotEmpty && !selectedColors.any((c) => c.toLowerCase() == color.toLowerCase())) {
      setState(() {
        selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
        selectedColors.add(color);
        _colorController.clear();
      });
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    try {
      print("Starting product save process...");

      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text.trim()) ?? 0.0;
      final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
      final description = descriptionController.text.trim();

      print("Validating inputs...");
      if (name.isEmpty) throw Exception("Product name cannot be empty");
      if (price <= 0) throw Exception("Price must be greater than 0");
      if (quantity < 0) throw Exception("Quantity cannot be negative");

      String? imageUrl;
      if (_imageFile != null) {
        print("Uploading image...");
        try {
          imageUrl = await uploadImage(_imageFile!);
          print("Image uploaded successfully: $imageUrl");
        } catch (e) {
          print("Image upload failed: $e");
          throw Exception("Image upload failed: $e");
        }
      } else {
        print("No image selected");
      }

      final product = {
        'name': name,
        'price': price,
        'quantity': quantity,
        'description': description,
        'image': imageUrl,
        'colors': selectedColors,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print("Saving to Firestore...");
      final docRef = await _firestore.collection('products').add(product);
      print("✅ Product saved with ID: ${docRef.id}");
print(product);
print (docRef);
      widget.updateTotals();

      // Reset the form
      setState(() {
        nameController.clear();
        priceController.clear();
        quantityController.clear();
        descriptionController.clear();
        _colorController.clear();
        selectedColors.clear();
        _imageFile = null;
        _formKey.currentState!.reset();
      });

      // Use the current context instead of parentContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );

      // Close the dialog after successful save
      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving product: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to add product: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Product"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
                validator: (value) => value == null || value.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Enter a valid price > 0';
                  return null;
                },
              ),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) return 'Enter valid quantity';
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Text("Add Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: 'Color Name',
                        hintText: 'Enter a color',
                      ),
                      onFieldSubmitted: (_) => _addColor(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: _addColor,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text("Selected Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: selectedColors.map((color) {
                  return Chip(
                    label: Text(color),
                    onDeleted: () {
                      setState(() {
                        selectedColors.remove(color);
                      });
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              Text("Available Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: availableColors.map((color) {
                  final isSelected = selectedColors.any((c) => c.toLowerCase() == color.toLowerCase());
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
                          selectedColors.add(color);
                        } else {
                          selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text("Product Image:", style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Center(child: Icon(Icons.add_a_photo, size: 50)),
                ),
              ),
              if (_imageFile != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  child: Text('Remove Image', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
        ElevatedButton(onPressed: () => _saveProduct(context), child: Text("Save")),
      ],
    );
  }
}
