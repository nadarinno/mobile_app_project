import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/reviews_logic.dart';
import 'package:mobile_app_project/View/Login.dart';

class ReviewsController extends ChangeNotifier {
  List<Map<String, dynamic>> productReviews = [];
  bool isLoading = true;
  String? errorMessage;
  final ReviewsLogic _logic = ReviewsLogic();
  final TextEditingController reviewController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> fetchReviews(String productId) async {
    print("Starting fetchReviews for productId: $productId at ${DateTime.now()}");
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reviews = await _logic.fetchReviews(productId);
      productReviews = reviews;
      print("Fetched ${productReviews.length} reviews for productId: $productId at ${DateTime.now()}");
      if (reviews.isNotEmpty) {
        print("Review data: ${reviews.map((r) => 'Text: ${r['text']}, User: ${r['userName']}, Time: ${r['timestamp']}').toList()}");
      } else {
        print("No reviews found for productId: $productId");
      }
    } catch (e) {
      print("Error in fetchReviews: $e at ${DateTime.now()}");
      errorMessage = e.toString();
      productReviews = [];
    } finally {
      isLoading = false;
      print("Fetch reviews completed, isLoading: $isLoading, error: $errorMessage at ${DateTime.now()}");
      notifyListeners();
    }
  }

  Future<void> submitReview(BuildContext context, String productId) async {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a review'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      return;
    }

    if (reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      print("Submitting review for productId: $productId at ${DateTime.now()}");
      await _logic.submitReview(
        productId: productId,
        reviewText: reviewController.text,
        userName: _auth.currentUser?.displayName ?? 'Anonymous',
      );

      await fetchReviews(productId); // Refresh reviews
      reviewController.clear();
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      print("Firebase error in submitReview: $e at ${DateTime.now()}");
      String message = 'Failed to submit review';
      if (e.code == 'permission-denied') {
        message = 'You do not have permission to submit reviews';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Unexpected error in submitReview: $e at ${DateTime.now()}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}