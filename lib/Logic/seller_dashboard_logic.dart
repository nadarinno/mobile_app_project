import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SellerDashboardLogic {

  Map<String, dynamic> calculateStats(List<QueryDocumentSnapshot> docs) {
    double totalSales = 0.0;
    int totalInventory = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = data['price'];
      final quantity = data['quantity'];

      if (price is num && quantity is num) {
        totalSales += price.toDouble() * quantity.toInt();
        totalInventory += quantity.toInt();
      }
    }

    return {
      'totalSales': totalSales,
      'totalInventory': totalInventory,
      'productCount': docs.length,
    };

}
}
