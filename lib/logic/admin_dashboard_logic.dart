import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardLogic {
  Stream<List<Map<String, dynamic>>> getSellersStream() {
    return FirebaseFirestore.instance
        .collection('sellers')
        .where('approved', isEqualTo: false)
        .snapshots()
        .map(
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

  Future<void> updateSellerStatus(String sellerId, bool status) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .update({'approved': status});
  }
}
