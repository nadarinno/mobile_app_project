import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final int id;
  final String type;
  final String productName;
  final String message;
  final DateTime timestamp;
  final bool read;

  NotificationModel({
    required this.id,
    required this.type,
    required this.productName,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: int.tryParse(docId) ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      type: data['type'] ?? 'new_product',
      productName: data['productName'] ?? 'Unknown',
      message: data['message'] ?? 'Notification received',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'productName': productName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }
}