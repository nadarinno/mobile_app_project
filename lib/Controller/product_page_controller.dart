
import 'package:flutter/material.dart';
import 'package:mobile_app_project/logic/product_logic.dart';
import 'package:mobile_app_project/Controller/product_card_controller.dart';
import 'package:mobile_app_project/logic/product_page_logic.dart';

class ProductsController {
  final ProductsLogic _logic = ProductsLogic();
  final ProductController _productController = ProductController();

  Stream<List<Product>> getProducts({
    String? category,
    required String searchQuery,
  }) {
    return _logic.getProducts(category: category, searchQuery: searchQuery);
  }

  Stream<bool> isSaved(String productId) {
    return _productController.isSaved(productId);
  }

  Future<void> toggleSaved(String productId, bool isSaved, BuildContext context) {
    return _productController.toggleSaved(productId, isSaved, context);
  }
}