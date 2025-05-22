import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'add_product.dart';
import 'utils.dart';
import 'dashboard_for_seller.dart';

Future<void> editProduct(BuildContext context, String docId, Map<String, dynamic> updatedProduct, File? imageFile, VoidCallback updateTotals) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    print("Attempting to update product ID: $docId with data: $updatedProduct");
    // Validate required fields
    if (updatedProduct['name'] == null || updatedProduct['name'].isEmpty) {
      throw Exception("Product name cannot be empty");
    }
    if (updatedProduct['price'] == null || updatedProduct['price'] <= 0) {
      throw Exception("Price must be greater than 0");
    }
    if (updatedProduct['quantity'] == null || updatedProduct['quantity'] < 0) {
      throw Exception("Quantity cannot be negative");
    }

    if (imageFile != null) {
      print("Uploading image...");
      final imageUrl = await uploadImage(imageFile);
      updatedProduct['image'] = imageUrl;
      print("Image uploaded: $imageUrl");
    }

    await _firestore.collection('products').doc(docId).update(updatedProduct);
    print("Product updated successfully");
    updateTotals();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product updated successfully')),
    );
  } catch (e) {
    print("Error updating product: $e");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text("Failed to update product: $e"),
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

void showEditProductForm(BuildContext context, Map<String, dynamic> product, String docId, VoidCallback updateTotals) {
  final _formKey = GlobalKey<FormState>();
  final _colorController = TextEditingController();
  List<String> selectedColors = (product['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
  List<String> availableColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow', 'Purple', 'Orange', 'Pink'];

  final nameController = TextEditingController(text: product['name']?.toString() ?? '');
  final priceController = TextEditingController(text: product['price']?.toString() ?? '');
  final quantityController = TextEditingController(text: product['quantity']?.toString() ?? '');
  final descriptionController = TextEditingController(text: product['description']?.toString() ?? '');
  File? _imageFile;

  void _addColor() {
    String color = _colorController.text.trim();
    if (color.isNotEmpty && !selectedColors.any((c) => c.toLowerCase() == color.toLowerCase())) {
      selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
      selectedColors.add(color);
      _colorController.clear();
    }
  }

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Product Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid whole number';
                      }
                      if (int.parse(value) < 0) {
                        return 'Quantity cannot be negative';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // Color Selection Section
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
                          onFieldSubmitted: (_) {
                            _addColor();
                            setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () {
                          _addColor();
                          setState(() {});
                        },
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
                    onTap: () async {
                      try {
                        _imageFile = await pickImage();
                        setState(() {});
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Error"),
                            content: Text("Failed to pick image: $e"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : product['image'] != null
                          ? Image.network(product['image'], fit: BoxFit.cover)
                          : Center(child: Icon(Icons.add_a_photo, size: 50)),
                    ),
                  ),
                  if (_imageFile != null || product['image'] != null)
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedProduct = {
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'description': descriptionController.text,
                    'colors': selectedColors,
                    'createdAt': FieldValue.serverTimestamp(),
                  };
                  print("Submitting product: $updatedProduct");
                  await editProduct(context, docId, updatedProduct, _imageFile, updateTotals);
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => SellerDashboard()),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    ),
  );
}