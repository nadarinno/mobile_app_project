import 'package:flutter/material.dart';
import 'package:mobile_app_project/logic/admin_dashboard_logic.dart';
import 'package:mobile_app_project/view/seller_detail_view.dart';
import 'package:mobile_app_project/logic/seller_detail_logic.dart';

class AdminDashboardController {
  final AdminDashboardLogic logic;

  AdminDashboardController(this.logic);

  void onSellerTap(BuildContext context, Map<String, dynamic> seller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerDetailPage(
          seller: Seller.fromMap(seller, seller['id']), // Convert Map to Seller
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> getSellersStream() {
    return logic.getSellersStream();
  }
}