// controllers/seller_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/logic/seller_detail_logic.dart';

class SellerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Approve a seller
  Future<void> approveSeller(BuildContext context, Seller seller) async {
    try {
      await _firestore.collection('sellers').doc(seller.id).update({
        'approved': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${seller.name} has been approved')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve seller: $e')),
      );
    }
  }

  // Reject (delete) a seller
  Future<void> rejectSeller(BuildContext context, Seller seller) async {
    try {
      await _firestore.collection('sellers').doc(seller.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${seller.name}')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject seller: $e')),
      );
    }
  }
}