import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/logic/AuthService.dart';

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

  // Login user and return status with role
  Future<Map<String, dynamic>?> login(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    // Notify UI to update
    (context as Element).markNeedsBuild();

    final result = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    isLoading = false;
    if (result['status'] == 'success') {
      // Role is already fetched in AuthService
      return result;
    } else {
      errorMessage = result['message'];
      // Notify UI to update
      (context as Element).markNeedsBuild();
      return result;
    }
  }

  // Dispose controllers
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}