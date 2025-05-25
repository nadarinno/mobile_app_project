import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/AuthService.dart';

class ForgotPasswordController {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  bool isSending = false;
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

  // Send password reset link
  Future<String?> sendResetLink(BuildContext context) async {
    isSending = true;
    errorMessage = null;
    // Notify UI to update
    (context as Element).markNeedsBuild();

    String? result = await _authService.resetPassword(
      email: emailController.text.trim(),
    );

    isSending = false;
    if (result != 'success') {
      errorMessage = result;
    }
    // Notify UI to update
    (context as Element).markNeedsBuild();

    return result;
  }

  // Dispose controller
  void dispose() {
    emailController.dispose();
  }
}