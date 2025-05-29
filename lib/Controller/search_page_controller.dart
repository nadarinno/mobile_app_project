
import 'package:flutter/material.dart';
import '../logic/category_logic.dart';
import '../view/product_page_view.dart';

class SearchPageController {
  final CategoryLogic _logic = CategoryLogic();

  Stream<List<Map<String, dynamic>>> getCategories() {
    return _logic.getCategories();
  }

  void navigateToResults(BuildContext context, String query, [String? category]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsView(
          searchQuery: query,
          categoryFilter: category,
        ),
      ),
    );
  }
}