import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/AuthService.dart';

class SignUpController {
  final AuthService _authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  // Validate name
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Register customer
  Future<String?> registerCustomer(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    // Notify UI to update
    (context as Element).markNeedsBuild();

    String? result = await _authService.registerCustomer(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    isLoading = false;
    if (result != 'success') {
      errorMessage = result;
    }
    // Notify UI to update
    (context as Element).markNeedsBuild();

    return result;
  }

  // Dispose controllers
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}