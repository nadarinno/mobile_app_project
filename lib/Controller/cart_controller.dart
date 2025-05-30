import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';
import 'package:mobile_app_project/Logic/cart_model.dart';
class CartController extends ChangeNotifier {
  final CartModel _cartModel;
  bool selectAll = false;
  bool isLoading = true;

  CartController({CartModel? cartModel}) : _cartModel = cartModel ?? CartModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing CartController: $e at ${DateTime.now()}');
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<CartItem>> get cartItems => _cartModel.getCartItems();

  Future<void> addToCart(CartItem item) async {
    try {
      await _cartModel.addToCart(item);
      notifyListeners();
    } catch (e) {
      print('Error adding to cart: $e at ${DateTime.now()}');
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      await _cartModel.updateQuantity(itemId, newQuantity);
      notifyListeners();
    } catch (e) {
      print('Error updating quantity: $e at ${DateTime.now()}');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _cartModel.removeItem(itemId);
      notifyListeners();
    } catch (e) {
      print('Error removing item: $e at ${DateTime.now()}');
    }
  }

  Future<void> toggleSelectAll(bool? value) async {
    try {
      selectAll = value ?? false;
      await _cartModel.toggleSelectAll(selectAll);
      notifyListeners();
    } catch (e) {
      print('Error toggling select all: $e at ${DateTime.now()}');
    }
  }

  double getTotalPrice(List<CartItem> items) {
    return _cartModel.calculateTotalPrice(items);
  }

  int getTotalItems(List<CartItem> items) {
    return _cartModel.calculateTotalItems(items);
  }

  Future<void> checkout(List<CartItem> items, BuildContext context) async {
    try {
      await _cartModel.checkout(items);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      notifyListeners();
    } catch (e) {
      print('Error during checkout: $e at ${DateTime.now()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }
}