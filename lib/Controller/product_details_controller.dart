import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/product_details_logic.dart';
import '../utils.dart' as utils;
import 'package:mobile_app_project/View/Login.dart';
class ProductDetailsController extends ChangeNotifier {
  int currentImageIndex = 0;
  bool isFavorite = false;
  bool isAddedToCart = false;
  bool showDescription = false;
  bool showReviews = false;
  String selectedColor = 'Black';
  String selectedSize = 'M';

  List<String> imagePaths = [];
  String productName = '';
  double productPrice = 0.0;
  String productDescription = '';
  List<String> productReviews = [];
  List<String> availableColors = [];
  List<String> availableSizes = [];
  String productId = '';

  bool isLoading = true;
  final ProductDetailsLogic _logic = ProductDetailsLogic();
  final TextEditingController reviewController = TextEditingController();

  // Add Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> fetchProductData(String productId) async {
    print("Starting fetchProductData for productId: $productId at ${DateTime.now()}");
    isLoading = true;
    notifyListeners();

    try {
      final data = await _logic.fetchProductData(productId);
      print("Fetched product data: $data at ${DateTime.now()}");

      imagePaths = List<String>.from(data['imagePaths'] ?? [])
          .where((img) => img.startsWith('http') && !img.contains('assets/'))
          .toList();
      if (imagePaths.isEmpty && (data['imagePaths']?.isNotEmpty ?? false)) {
        print("Filtered invalid imagePaths: ${data['imagePaths']} at ${DateTime.now()}");
      }

      productName = data['productName'] ?? 'Unknown Product';
      productPrice = (data['productPrice'] ?? 0.0).toDouble();
      productDescription = data['productDescription'] ?? 'No description available';
      productReviews = List<String>.from(data['productReviews'] ?? []);
      availableColors = List<String>.from(data['availableColors'] ?? ['Black', 'White']);
      availableSizes = List<String>.from(data['availableSizes'] ?? ['S', 'M', 'L']);
      this.productId = data['productId'] ?? '';

      if (availableColors.isNotEmpty) {
        selectedColor = availableColors.first;
      }
      if (availableSizes.isNotEmpty) {
        selectedSize = availableSizes.first;
      }

      if (imagePaths.isEmpty) {
        print("No valid image paths from Firestore, UI will use fallback at ${DateTime.now()}");
      }
    } catch (e) {
      print("Error in fetchProductData: $e at ${DateTime.now()}");
      imagePaths = [];
    } finally {
      isLoading = false;
      print("Fetch completed, isLoading: $isLoading, productName: $productName at ${DateTime.now()}");
      notifyListeners();
    }
  }

  Future<void> addToCart(BuildContext context) async {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to your cart'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      return;
    }

    try {
      print("Adding to cart for productId: $productId at ${DateTime.now()}");
      await _logic.addToCart(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        imagePaths: imagePaths,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );

      isAddedToCart = true;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart!'),
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        isAddedToCart = false;
        notifyListeners();
      });
    } catch (e) {
      print("Error in addToCart: $e at ${DateTime.now()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> submitReview(BuildContext context) async {
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
      );

      // Fetch updated product data, including reviews from the subcollection
      final data = await _logic.fetchProductData(productId);
      productReviews = List<String>.from(data['productReviews'] ?? []);

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

  Future<void> uploadProductImage(BuildContext context) async {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to upload images'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      return;
    }

    try {
      final File? imageFile = await utils.pickImage();
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final imageUrl = await utils.uploadImage(imageFile);
      print("Image uploaded successfully: $imageUrl at ${DateTime.now()}");

      if (!imageUrl.startsWith('http') || imageUrl.contains('assets/')) {
        throw Exception('Invalid image URL received: $imageUrl');
      }

      imagePaths.add(imageUrl);
      await _logic.updateProductImages(productId, imagePaths);

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error uploading product image: $e at ${DateTime.now()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getColorFromName(String colorName) {
    return utils.getColorFromName(colorName);
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void setCurrentImageIndex(int index) {
    currentImageIndex = index;
    notifyListeners();
  }

  void setSelectedColor(String color) {
    selectedColor = color;
    notifyListeners();
  }

  void setSelectedSize(String size) {
    selectedSize = size;
    notifyListeners();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}