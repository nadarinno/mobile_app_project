import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/product_details_logic.dart';

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

  Future<void> fetchProductData(String productId) async {
    isLoading = true;
    notifyListeners();

    final data = await _logic.fetchProductData(productId);

    imagePaths = data['imagePaths'] ?? [];
    productName = data['productName'] ?? '';
    productPrice = data['productPrice'] ?? 0.0;
    productDescription = data['productDescription'] ?? '';
    productReviews = data['productReviews'] ?? [];
    availableColors = data['availableColors'] ?? ['Black', 'White'];
    availableSizes = data['availableSizes'] ?? [];
    this.productId = data['productId'] ?? '';

    // Set initial selections only if lists are not empty
    if (availableColors.isNotEmpty) {
      selectedColor = availableColors[0];
    }
    if (availableSizes.isNotEmpty) {
      selectedSize = availableSizes[0];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(BuildContext context) async {
    try {
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
        SnackBar(
          content: Text('Added to cart!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        isAddedToCart = false;
        notifyListeners();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void setCurrentImageIndex(int index) {
    currentImageIndex = index;
    notifyListeners();
  }

  void toggleDescription() {
    showDescription = !showDescription;
    notifyListeners();
  }

  void toggleReviews() {
    showReviews = !showReviews;
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

  Color getColorFromName(String colorName) {
    try {
      String normalized = colorName.replaceAll('"', '').trim().toLowerCase();
      print("Converting color: $normalized");

      switch (normalized) {
        case 'white':
          return Colors.white;
        case 'black':
          return Colors.black;
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'pink':
          return Colors.pink;
        default:
          print("Unknown color: $normalized, using grey");
          return Colors.grey;
      }
    } catch (e) {
      print("Error in getColorFromName: $e");
      return Colors.grey;
    }
  }
}