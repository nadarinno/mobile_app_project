import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/cart_controller.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';
import 'package:mobile_app_project/Logic/checkout_model.dart';
import 'package:provider/provider.dart';

class CheckoutController extends ChangeNotifier {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CheckoutModel _checkoutModel = CheckoutModel();
  bool isLoading = false;

  TextEditingController get nameController => _nameController;
  TextEditingController get addressController => _addressController;
  TextEditingController get phoneController => _phoneController;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> confirmOrder(
    BuildContext context,
    List<CartItem> cartItems,
  ) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();

      try {
        final cartController = Provider.of<CartController>(
          context,
          listen: false,
        );
        await _checkoutModel.createOrder(
          cartItems,
          cartController.getTotalPrice(cartItems),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        // Clear the cart after successful order
        await cartController.clearCart();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error during checkout: $e')));
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
