import 'package:mobile_app_project/Logic/product_card_logic.dart';
import 'package:mobile_app_project/logic/product_logic.dart';


class ProductsLogic extends ProductLogic {
  Stream<List<Product>> getProducts({
    String? category,
    required String searchQuery,
  }) {
    return productsStream(category: category, searchQuery: searchQuery);
  }
}