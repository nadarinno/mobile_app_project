import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/logic/product_card_logic.dart';
import 'product_logic.dart';

class ProductsLogic extends ProductLogic {
  Stream<List<Product>> getProducts({
    String? category,
    required String searchQuery,
  }) {
    return productsStream(category: category, searchQuery: searchQuery);
  }
}