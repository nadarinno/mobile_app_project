// logic/order_management_logic.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/logic/product_logic.dart';

class OrderManagementLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': "Order ${doc.id}",
          'status': data['status'] ?? 'Pending',
          'date': (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'price': data['totalAmount']?.toDouble() ?? 0.0,
          'details': data['shippingAddress'] ?? '',
          'productsIds': List<String>.from(data['products'] ?? []),
        };
      }).toList();
    } catch (e) {
      print('❌ Failed to fetch orders: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductsForOrder(List<String> productIds) async {
    if (productIds.isEmpty) return [];
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();
      return productsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Failed to fetch products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductDetails(
      List<String> productIds) async {
    final List<Map<String, dynamic>> products = [];
    try {
      for (String id in productIds) {
        final doc = await _firestore.collection('products').doc(id).get();
        if (doc.exists) {
          final data = doc.data()!;
          products.add({
            'id': doc.id,
            'productName': data['name'] ?? 'Unknown',
            'price': data['price']?.toDouble() ?? 0.0,
            'imageUrl': data['imageUrl'] ?? '',
            'isSaved': data['isSaved'] ?? false,
            'category': data['category'] ?? 'General',
          });
        }
      }
      return products;
    } catch (e) {
      print('❌ Failed to fetch product details: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      return true;
    } catch (e) {
      print('❌ Failed to update order status: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> sortOrders(
      List<Map<String, dynamic>> orders, String sortOption) {
    final sortedOrders = List<Map<String, dynamic>>.from(orders);
    switch (sortOption) {
      case 'Date (Oldest to Newest)':
        sortedOrders.sort((a, b) => a['date'].compareTo(b['date']));
        break;
      case 'Date (Newest to Oldest)':
        sortedOrders.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case 'Price (High to Low)':
        sortedOrders.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Price (Low to High)':
        sortedOrders.sort((a, b) => a['price'].compareTo(a['price']));
        break;
      case 'Status':
        sortedOrders.sort((a, b) => a['status'].compareTo(b['status']));
        break;
    }
    return sortedOrders;
  }
}