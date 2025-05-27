// controllers/settings_controller.dart
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

  Future<void> deleteAccount(BuildContext context, bool isArabic) async {
    final success = await _logic.deleteAccount(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (isArabic ? 'تم حذف الحساب بنجاح' : 'Account deleted successfully')
            : (isArabic ? 'فشل حذف الحساب' : 'Failed to delete account')),
        backgroundColor: success ? Colors.green : const Color(0xFF561C24),
      ),
    );
  }

  void validateEmail(String email, bool isArabic) {
    emailError = _logic.validateEmail(email, isArabic);
    emailValid = emailError == null;
  }

  void validatePhone(String phone, bool isArabic) {
    phoneError = _logic.validatePhone(phone, isArabic);
    phoneValid = phoneError == null;
  }

  void validateName(String name, bool isArabic) {
    nameError = _logic.validateName(name, isArabic);
    nameValid = nameError == null;
  }

  void validateLocation(String location, bool isArabic) {
    locationError = _logic.validateLocation(location, isArabic);
    locationValid = locationError == null;
  }
}