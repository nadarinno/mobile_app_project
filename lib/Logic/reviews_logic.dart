import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsLogic {
  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();
      final reviews = reviewsSnapshot.docs.map((doc) {
        return {
          'text': doc['text'] as String,
          'userId': doc['userId'] as String,
          'timestamp': doc['timestamp'] as Timestamp,
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
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Review submitted successfully for productId: $productId at ${DateTime.now()}");
    } catch (e) {
      print("Error submitting review: $e at ${DateTime.now()}");
      throw Exception("Failed to submit review: $e");
    }
  }
}