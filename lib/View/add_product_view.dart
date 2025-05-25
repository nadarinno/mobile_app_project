import 'dart:io';
import 'package:flutter/material.dart';
import '../Controller/add_product_controller.dart';
import '../Logic/add_product_logic.dart';

class AddProductView extends StatefulWidget {
  final VoidCallback updateTotals;
  final BuildContext parentContext;
  final AddProductController controller;
  final AddProductLogic logic;

  AddProductView({
    required this.updateTotals,
    required this.parentContext,
    required this.controller,
    required this.logic,
  });

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();

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
              Text("Add Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text("Selected Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: widget.logic.selectedColors.map((color) {
                  return Chip(
                    label: Text(color),
                    onDeleted: () {
                      widget.logic.removeColor(color);
                      setState(() {});
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              Text("Available Colors:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: widget.logic.availableColors.map((color) {
                  final isSelected = widget.logic.selectedColors.any((c) => c.toLowerCase() == color.toLowerCase());
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      widget.logic.toggleColor(color, selected);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text("Product Images:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () {
                              widget.logic.removeImage(index);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: () async {
                      await widget.logic.pickImage();
                      setState(() {});
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Icon(Icons.add_a_photo, size: 50)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () => widget.controller.saveProduct(context, _formKey, widget.updateTotals, widget.logic),
          child: Text("Save"),
        ),
      ],
    );
  }
}