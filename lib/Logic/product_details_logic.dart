import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchProductData(String productId) async {
    try {
      print("Fetching product data...");
      DocumentSnapshot doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("Raw data from Firestore: $data");

        // Handle colors with better error checking
        List<String> colors = [];
        if (data['colors'] != null) {
          try {
            colors = (data['colors'] as List).map((item) => item.toString().trim()).toList();
          } catch (e) {
            print("Error parsing colors: $e");
            colors = ['Black', 'White']; // Default fallback
          }
        } else {
          colors = ['Black', 'White']; // Default fallback
        }

        return {
          'imagePaths': List<String>.from(data['images'] ?? []),
          'productName': data['name'] ?? '',
          'productPrice': (data['price'] ?? 0).toDouble(),
          'productDescription': data['description'] ?? '',
          'productReviews': List<String>.from(data['reviews'] ?? []),
          'availableColors': colors,
          'availableSizes': List<String>.from(data['sizes'] ?? []),
          'productId': doc.id,
        };
      } else {
        print("Document doesn't exist");
        return {
          'availableColors': ['Black', 'White'], // Default fallback
        };
      }
    } catch (e) {
      print("Error fetching product data: $e");
      return {
        'availableColors': ['Black', 'White'], // Default fallback
      };
    }
  }

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double productPrice,
    required List<String> imagePaths,
    required String selectedColor,
    required String selectedSize,
  }) async {
    try {
      print("Adding to cart with data: ");
      print("productId: $productId");
      print("productName: $productName");
      print("productPrice: $productPrice");
      print("imagePaths: $imagePaths");
      print("selectedColor: $selectedColor");
      print("selectedSize: $selectedSize");

      // Check if this product is already in the cart
      final querySnapshot = await _firestore
          .collection('cart')
          .where('productId', isEqualTo: productId)
          .where('color', isEqualTo: selectedColor)
          .where('size', isEqualTo: selectedSize)
          .limit(1)
          .get();

      print("Query snapshot: ${querySnapshot.docs.length} documents found");

      if (querySnapshot.docs.isNotEmpty) {
        // Product exists in cart, update quantity
        final doc = querySnapshot.docs.first;
        print("Updating existing cart item: ${doc.id}");
        await doc.reference.update({
          'quantity': FieldValue.increment(1),
        });
        print("Cart item updated successfully");
      } else {
        // Product doesn't exist in cart, add new item
        print("Adding new item to cart");
        await _firestore.collection('cart').add({
          'productId': productId,
          'name': productName,
          'price': productPrice,
          'image': imagePaths.isNotEmpty ? imagePaths[0] : '',
          'color': selectedColor,
          'size': selectedSize,
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("New cart item added successfully");
      }
    } catch (e) {
      print("Error adding to cart: $e");
      rethrow;
    }
  }
}