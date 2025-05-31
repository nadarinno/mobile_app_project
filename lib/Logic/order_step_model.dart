import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Model class for OrderStep
class OrderStep {
  final String title;
  final String description;
  final String estimate;
  final IconData icon;

  OrderStep({
    required this.title,
    required this.description,
    required this.estimate,
    required this.icon,
  });

  factory OrderStep.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderStep(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      estimate: data['estimate'] ?? '',
      icon: getIconData(data['icon'] ?? ''),
    );
  }

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'inventory':
        return Icons.inventory;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'favorite_border':
        return Icons.favorite_border;
      default:
        return Icons.help_outline;
    }
  }
}