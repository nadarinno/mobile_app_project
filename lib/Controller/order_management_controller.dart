
import 'package:mobile_app_project/logic/order_management_logic.dart';
import 'package:mobile_app_project/logic/product_logic.dart';

class OrderManagementController {
  final OrderManagementLogic _logic = OrderManagementLogic();
  List<Map<String, dynamic>> orders = [];
  Map<String, List<Product>> orderProducts = {};
  String selectedSort = 'Date (Oldest to Newest)';
  final List<String> sortOptions = [
    'Date (Oldest to Newest)',
    'Date (Newest to Oldest)',
    'Price (High to Low)',
    'Price (Low to High)',
    'Status',
  ];

  Future<void> fetchOrders() async {
    orders = await _logic.fetchOrders();
    for (var order in orders) {
      final productIds = List<String>.from(order['productsIds'] ?? []);
      orderProducts[order['id']] = await _logic.fetchProductsForOrder(productIds);
    }
    sortOrders();
  }

  Future<List<Map<String, dynamic>>> fetchProductDetails(
      List<String> productIds) async {
    return await _logic.fetchProductDetails(productIds);
  }

  void sortOrders() {
    orders = _logic.sortOrders(orders, selectedSort);
  }

  Future<void> updateOrderStatus(int index, String newStatus) async {
    final orderId = orders[index]['id'];
    final success = await _logic.updateOrderStatus(orderId, newStatus);
    if (success) {
      orders[index]['status'] = newStatus;
    }
  }

  void setSortOption(String sortOption) {
    selectedSort = sortOption;
    sortOrders();
  }
}