import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/AuthService.dart';

class ChangePasswordController {
  final AuthService _authService = AuthService();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isChanging = false;
  String? errorMessage;

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value.trim() != newPasswordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Change password
  Future<String?> changePassword(BuildContext context) async {
    isChanging = true;
    errorMessage = null;
    // Notify UI to update
    (context as Element).markNeedsBuild();

    String? result = await _authService.changePassword(
      newPassword: newPasswordController.text.trim(),
    );

    isChanging = false;
    if (result != 'success') {
      errorMessage = result;
    }
    // Notify UI to update
    (context as Element).markNeedsBuild();

    return result;
  }

  // Dispose controllers
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}