import 'package:flutter/material.dart';
import 'package:mobile_app_project/logic/settings_logic.dart';

class SettingsController {
  final SettingsLogic _logic = SettingsLogic();
  Map<String, dynamic>? userData;
  String? emailError;
  String? phoneError;
  String? nameError;
  String? locationError;
  bool emailValid = false;
  bool phoneValid = false;
  bool nameValid = false;
  bool locationValid = false;

  Future<void> loadUserProfile() async {
    userData = await _logic.loadUserProfile();
  }

  Future<void> updateUserProfile(BuildContext context, Map<String, dynamic> updatedData) async {
    final success = await _logic.updateUserProfile(updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile updated successfully!'
            : 'Failed to update profile'),
        backgroundColor: success ? Colors.green : const Color(0xFF561C24),
      ),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    final success = await _logic.deleteAccount(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Account deleted successfully'
            : 'Failed to delete account'),
        backgroundColor: success ? Colors.green : const Color(0xFF561C24),
      ),
    );
  }

  void validateEmail(String email) {
    emailError = _logic.validateEmail(email);
    emailValid = emailError == null;
  }

  void validatePhone(String phone) {
    phoneError = _logic.validatePhone(phone);
    phoneValid = phoneError == null;
  }

  void validateName(String name) {
    nameError = _logic.validateName(name);
    nameValid = nameError == null;
  }

  void validateLocation(String location) {
    locationError = _logic.validateLocation(location);
    locationValid = locationError == null;
  }
}