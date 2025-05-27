import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Controller/edit_product_controller.dart';
import '../Logic/edit_product_logic.dart';
import 'seller_dashboard_view.dart';
import '../Controller/seller_dashboard_controller.dart';
import '../Logic/seller_dashboard_logic.dart';

class EditProductView extends StatefulWidget {
  final Map<String, dynamic> product;
  final String docId;
  final VoidCallback updateTotals;
  final EditProductController controller;
  final EditProductLogic logic;

  EditProductView({
    required this.product,
    required this.docId,
    required this.updateTotals,
    required this.controller,
    required this.logic,
  });

  @override
  _EditProductViewState createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Product"),
      content: SingleChildScrollView(
        child: Form(
          key: widget.logic.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widget.logic.nameController,
                decoration: InputDecoration(labelText: "Product Name"),
                validator: widget.logic.validateName,
              ),
              TextFormField(
                controller: widget.logic.priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: widget.logic.validatePrice,
              ),
              TextFormField(
                controller: widget.logic.quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: widget.logic.validateQuantity,
              ),
              TextFormField(
                controller: widget.logic.descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Text(
                "Add Colors:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.logic.colorController,
                      decoration: InputDecoration(
                        labelText: 'Color Name',
                        hintText: 'Enter a color',
                      ),
                      onFieldSubmitted: (_) {
                        widget.logic.addColor();
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      widget.logic.addColor();
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Selected Colors:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children:
                    widget.logic.selectedColors.map((color) {
                      return Chip(
                        label: Text(color),
                        onDeleted: () {
                          setState(() {
                            widget.logic.removeColor(color);
                          });
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                      );
                    }).toList(),
              ),
              SizedBox(height: 8),
              Text(
                "Available Colors:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children:
                    widget.logic.availableColors.map((color) {
                      final isSelected = widget.logic.selectedColors.any(
                        (c) => c.toLowerCase() == color.toLowerCase(),
                      );
                      return FilterChip(
                        label: Text(color),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            widget.logic.toggleColor(color, selected);
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                "Product Image:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    await widget.logic.pickImage();
                    setState(() {});
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
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
                  child:
                      widget.logic.imageFile != null
                          ? Image.file(
                            widget.logic.imageFile!,
                            fit: BoxFit.cover,
                          )
                          : widget.product['image'] != null
                          ? Image.network(
                            widget.product['image'],
                            fit: BoxFit.cover,
                          )
                          : Center(child: Icon(Icons.add_a_photo, size: 50)),
                ),
              ),
              if (widget.logic.imageFile != null ||
                  widget.product['image'] != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.logic.removeImage();
                    });
                  },
                  child: Text(
                    'Remove Image',
                    style: TextStyle(color: Colors.red),
                  ),
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
            await widget.controller.saveProduct(
              context,
              widget.docId,
              widget.logic,
              widget.updateTotals,
              () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (_) => SellerDashboardView(
                          controller: SellerDashboardController(
                            FirebaseFirestore.instance,
                          ),
                          logic: SellerDashboardLogic(),
                        ),
                  ),
                );
              },
            );
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
