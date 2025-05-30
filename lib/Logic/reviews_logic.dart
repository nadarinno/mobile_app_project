import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsLogic {
  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    try {
      print("Querying reviews for productId: $productId at ${DateTime.now()}");
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();
      final reviews = reviewsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'text': data['text'] as String? ?? 'No text',
          'userId': data['userId'] as String? ?? 'unknown',
          'userName': data['userName'] as String? ?? 'Anonymous',
          'timestamp': data['timestamp'] as Timestamp? ?? Timestamp.now(),
        };
      }).toList();
      print("Fetched ${reviews.length} reviews for productId: $productId at ${DateTime.now()}");
      return reviews;
    } catch (e) {
      print("Error fetching reviews: $e at ${DateTime.now()}");
      throw Exception("Failed to load reviews: $e");
    }
  }

  Future<void> submitReview({
    required String productId,
    required String reviewText,
    required String userName,
  }) async {
    try {
      print("Submitting review for productId: $productId at ${DateTime.now()}");
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add({
        'text': reviewText,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Review submitted successfully for productId: $productId at ${DateTime.now()}");
    } catch (e) {
      print("Error submitting review: $e at ${DateTime.now()}");
      throw Exception("Failed to submit review: $e");
    }
  }
}