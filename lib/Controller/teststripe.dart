import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['images'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'images': imagePath,
      'quantity': quantity,
    };
  }
}

class CartController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _selectAll = false;
  bool _isLoading = true;

  CartController() {
    _initialize();
  }

  bool get selectAll => _selectAll;
  bool get isLoading => _isLoading;

  void _initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
      if (stripeKey == null || stripeKey.isEmpty) {
        throw Exception('STRIPE_PUBLISHABLE_KEY not found in .env file');
      }
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      print('Error initializing Stripe: $e');
      // Optionally notify UI of initialization failure
      _isLoading = false;
      notifyListeners();
      return;
    }

    Future.delayed(Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  Stream<List<CartItem>> getCartItems() {
    return _firestore.collection('cart').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _firestore.collection('cart').doc(itemId).delete();
    } else {
      await _firestore
          .collection('cart')
          .doc(itemId)
          .update({'quantity': newQuantity});
    }
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    await _firestore.collection('cart').doc(itemId).delete();
    notifyListeners();
  }

  Future<void> toggleSelectAll(bool? value) async {
    _selectAll = value ?? false;
    final snapshot = await _firestore.collection('cart').get();
    if (_selectAll) {
      for (var doc in snapshot.docs) {
        await doc.reference.update({'quantity': 1});
      }
    } else {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
    notifyListeners();
  }

  double calculateTotalPrice(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int calculateTotalItems(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-url.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['clientSecret'];
      } else {
        print('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating payment intent: $e');
      return null;
    }
  }

  Future<void> checkout(List<CartItem> items, BuildContext context) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate total amount
      final totalAmount = calculateTotalPrice(items);
      // Create Payment Intent
      final clientSecret = await createPaymentIntent(totalAmount, 'usd');
      if (clientSecret == null) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize payment')),
        );
        return;
      }

      // Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your Store',
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // Set to false in production
          ),
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If payment is successful, proceed with Firestore operations
      final batch = _firestore.batch();
      final ordersRef = _firestore.collection('orders').doc();

      batch.set(ordersRef, {
        'date': DateTime.now(),
        'items': items.map((item) => item.toMap()).toList(),
        'total': totalAmount,
        'paymentStatus': 'completed',
      });

      for (var item in items) {
        batch.delete(_firestore.collection('cart').doc(item.id));
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}