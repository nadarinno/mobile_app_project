// controllers/product_card_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../logic/product_logic.dart';
import '../logic/product_card_logic.dart';

class ProductController {
  final ProductLogic _logic = ProductLogic();

  Stream<List<Product>> getProducts({
    String? category,
    required String searchQuery,
  }) {
    return _logic.productsStream(category: category, searchQuery: searchQuery);
  }

  Stream<bool> isSaved(String productId) {
    return _logic.isSaved(productId);
  }

  Future<void> toggleSaved(String productId, bool isCurrentlySaved, BuildContext context) async {
    final success = isCurrentlySaved
        ? await _logic.deleteSavedItem(productId)
        : await _logic.saveItem(productId);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحديث حالة الحفظ')),
      );
    }
  }
}