import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsLogic {
  Future<Map<String, dynamic>> fetchProductData(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();

      if (!doc.exists) {
        throw Exception("Product not found");
      }

      final data = doc.data()!;
      print("Raw document data for productId $productId: $data at ${DateTime.now()}");

      List<String> images = [];
      if (data['images'] != null) {
        var rawImages = List<String>.from(data['images']);
        images = rawImages.where((img) => img.startsWith('http') && !img.contains('assets/')).toList();
        if (images.length != rawImages.length) {
          print("Filtered out invalid images for productId $productId: $rawImages -> $images at ${DateTime.now()}");
        }
      } else if (data['image'] != null) {
        String image = data['image'].toString();
        if (image.startsWith('http') && !image.contains('assets/')) {
          images = [image];
        } else {
          print("Invalid image URL filtered for productId $productId: $image at ${DateTime.now()}");
        }
      }

      if (images.isEmpty) {
        print("No valid HTTP image URLs found for productId: $productId at ${DateTime.now()}");
      }

      String name = data['name'] ?? data['(name'] ?? 'Unknown Product';

      List<String> colors = [];
      if (data['colors'] != null) {
        colors = List<String>.from(data['colors']);
      } else {
        colors = ['Black', 'White'];
      }

      List<String> sizes = [];
      if (data['sizes'] != null) {
        sizes = List<String>.from(data['sizes']);
      } else {
        sizes = ['S', 'M', 'L'];
      }

      return {
        'imagePaths': images,
        'productName': name,
        'productPrice': (data['price'] is num ? data['price'].toDouble() : 0.0),
        'productDescription': data['description']?.toString() ?? 'No description available',
        'availableColors': colors,
        'availableSizes': sizes,
        'productId': productId,
      };
    } catch (e) {
      print("Error fetching product: $e at ${DateTime.now()}");
      throw Exception("Failed to load product: $e");
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      // Ensure the users/{userId} document exists
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist. Please complete your profile.");
      }

      // Check for existing cart item with same productId, color, and size
      final cartQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .where('productId', isEqualTo: productId)
          .where('color', isEqualTo: selectedColor)
          .where('size', isEqualTo: selectedSize)
          .limit(1)
          .get();

      if (cartQuery.docs.isNotEmpty) {
        // Update quantity if item exists
        final cartItem = cartQuery.docs.first;
        final currentQuantity = cartItem.data()['quantity'] as int;
        await cartItem.reference.update({
          'quantity': currentQuantity + 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("Updated quantity for cart item ${cartItem.id} for productId: $productId at ${DateTime.now()}");
      } else {
        // Add new cart item
        final cartData = {
          'productId': productId,
          'name': productName,
          'price': productPrice,
          'image': imagePaths.isNotEmpty ? imagePaths.first : '',
          'color': selectedColor,
          'size': selectedSize,
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
        };
        print("Adding new cart item with data: $cartData at ${DateTime.now()}");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add(cartData);
        print("Successfully added new cart item for productId: $productId at ${DateTime.now()}");
      }
    } catch (e) {
      print("Error adding to cart: $e at ${DateTime.now()}");
      throw Exception("Failed to add to cart: $e");
    }
  }

  Future<void> updateProductImages(String productId, List<String> imagePaths) async {
    try {
      final validImagePaths = imagePaths.where((img) => img.startsWith('http') && !img.contains('assets/')).toList();
      if (validImagePaths.length != imagePaths.length) {
        print("Filtered invalid image paths for productId $productId: $imagePaths -> $validImagePaths at ${DateTime.now()}");
      }
      print("Updating product images for productId: $productId with $validImagePaths at ${DateTime.now()}");
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'images': validImagePaths,
      });
      print("Updated product images for $productId: $validImagePaths at ${DateTime.now()}");
    } catch (e) {
      print("Error updating product images: $e at ${DateTime.now()}");
      throw Exception("Failed to update product images: $e");
    }
  }
}