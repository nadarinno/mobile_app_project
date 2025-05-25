import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/AuthService.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

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

  // Login user
  Future<String?> login(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    // Notify UI to update
    (context as Element).markNeedsBuild();

    String? result = await _authService.login(
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
    emailController.dispose();
    passwordController.dispose();
  }
}