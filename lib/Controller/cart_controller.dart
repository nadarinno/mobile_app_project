import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';

class CartController extends ChangeNotifier {
  final CartModel _cartModel = CartModel();
  bool selectAll = false;
  bool isLoading = true;

  CartController() {
    _initialize();
  }

  void _initialize() async {
    await Future.delayed(Duration(seconds: 1));
    isLoading = false;
    notifyListeners();
  }

  Stream<List<CartItem>> get cartItems => _cartModel.getCartItems();

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    await _cartModel.updateQuantity(itemId, newQuantity);
    notifyListeners();
  }

  Future<void> removeItem(String itemId) async {
    await _cartModel.removeItem(itemId);
    notifyListeners();
  }

  Future<void> toggleSelectAll(bool? value) async {
    selectAll = value ?? false;
    await _cartModel.toggleSelectAll(selectAll);
    notifyListeners();
  }

  double getTotalPrice(List<CartItem> items) {
    return _cartModel.calculateTotalPrice(items);
  }

  int getTotalItems(List<CartItem> items) {
    return _cartModel.calculateTotalItems(items);
  }

  Future<void> checkout(List<CartItem> items, BuildContext context) async {
    await _cartModel.checkout(items);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully!')),
    );
    notifyListeners();
  }
}