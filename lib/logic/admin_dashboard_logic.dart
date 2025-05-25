import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardLogic {
  Stream<List<Map<String, dynamic>>> getSellersStream() {
    return FirebaseFirestore.instance.collection('sellers').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'location': data['location'] ?? '',
          'business': data['business'] ?? '',
          'approved': data['approved'] ?? false,
        };
      }).toList(),
    );
  }
}