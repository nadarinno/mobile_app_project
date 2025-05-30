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
      title: Text("Edit Product", style: TextStyle(color: Color(0xFF561C24))),
      backgroundColor: Color(0xFFF5F3ED),
      content: SingleChildScrollView(
        child: Form(
          key: widget.logic.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widget.logic.nameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  labelStyle: TextStyle(color: Color(0xFF561C24)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF561C24)),
                  ),
                ),
                validator: widget.logic.validateName,
                style: TextStyle(color: Color(0xFF561C24)),
              ),
              TextFormField(
                controller: widget.logic.priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(color: Color(0xFF561C24)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF561C24)),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: widget.logic.validatePrice,
                style: TextStyle(color: Color(0xFF561C24)),
              ),
              TextFormField(
                controller: widget.logic.quantityController,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  labelStyle: TextStyle(color: Color(0xFF561C24)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF561C24)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: widget.logic.validateQuantity,
                style: TextStyle(color: Color(0xFF561C24)),
              ),
              TextFormField(
                controller: widget.logic.descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Color(0xFF561C24)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF561C24)),
                  ),
                ),
                maxLines: 3,
                style: TextStyle(color: Color(0xFF561C24)),
              ),
              SizedBox(height: 16),
              Text(
                "Add Colors:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF561C24),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.logic.colorController,
                      decoration: InputDecoration(
                        labelText: 'Color Name',
                        hintText: 'Enter a color',
                        labelStyle: TextStyle(color: Color(0xFF561C24)),
                        hintStyle: TextStyle(
                          color: Color(0xFF561C24).withOpacity(0.6),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF561C24)),
                        ),
                      ),
                      onFieldSubmitted: (_) {
                        widget.logic.addColor();
                        setState(() {});
                      },
                      style: TextStyle(color: Color(0xFF561C24)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Color(0xFF561C24)),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF561C24),
                ),
              ),
              Wrap(
                spacing: 8,
                children:
                    widget.logic.selectedColors.map((color) {
                      return Chip(
                        label: Text(
                          color,
                          style: TextStyle(color: Color(0xFF561C24)),
                        ),
                        backgroundColor: Color(0xFFD0B8A8),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF561C24),
                        ),
                        onDeleted: () {
                          widget.logic.removeColor(color);
                          setState(() {});
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 8),
              Text(
                "Available Colors:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF561C24),
                ),
              ),
              Wrap(
                spacing: 8,
                children:
                    widget.logic.availableColors.map((color) {
                      final isSelected = widget.logic.selectedColors.any(
                        (c) => c.toLowerCase() == color.toLowerCase(),
                      );
                      return FilterChip(
                        label: Text(
                          color,
                          style: TextStyle(color: Color(0xFF561C24)),
                        ),
                        selected: isSelected,
                        backgroundColor: Color(0xFFD0B8A8),
                        selectedColor: Color(0xFFD0B8A8).withOpacity(0.5),
                        onSelected: (selected) {
                          widget.logic.toggleColor(color, selected);
                          setState(() {});
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                "Product Images:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF561C24),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...widget.logic.imageFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF561C24)),
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFF5F3ED),
                          ),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF561C24),
                            ),
                            onPressed: () {
                              widget.logic.removeImage(index);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  ...(widget.product['images'] as List<dynamic>? ?? [])
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final imageUrl = entry.value as String;
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF561C24)),
                                borderRadius: BorderRadius.circular(8),
                                color: Color(0xFFF5F3ED),
                              ),
                              child: Image.network(imageUrl, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF561C24),
                                ),
                                onPressed: () {
                                  widget.logic.removeExistingImage(index);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),
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
                                title: Text(
                                  "Error",
                                  style: TextStyle(color: Color(0xFF561C24)),
                                ),
                                backgroundColor: Color(0xFFF5F3ED),
                                content: Text(
                                  "Failed to pick image: $e",
                                  style: TextStyle(color: Color(0xFF561C24)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Color(0xFF561C24),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color(0xFFD0B8A8),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF561C24)),
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFFF5F3ED),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Color(0xFF561C24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel", style: TextStyle(color: Color(0xFF561C24))),
          style: TextButton.styleFrom(backgroundColor: Color(0xFFD0B8A8)),
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
          child: Text("Save", style: TextStyle(color: Color(0xFFF5F3ED))),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD0B8A8),
            foregroundColor: Color(0xFF561C24),
          ),
        ),
      ],
    );
  }
}
