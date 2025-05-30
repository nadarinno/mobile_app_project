// logic/search_logic.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs
          .map((doc) => doc['name'] as String)
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('❌ Error fetching suggestions: $e');
      return [];
    }
  }
}