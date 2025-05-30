import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('❌ No user logged in');
        return null;
      }
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = uid; // Include document ID
        print('✔️ Data loaded for user: $uid');
        return data;
      } else {
        print('⚠️ User document not found!');
        return null;
      }
    } catch (e) {
      print('❌ Failed to load user data: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('users').doc(uid).update({
        'name': userData['name']?.trim() ?? '',
        'email': userData['email']?.trim() ?? '',
        'phone': userData['phone']?.trim() ?? '',
        'location': userData['location']?.trim() ?? '',
        'notificationsEnabled': userData['notificationsEnabled'] ?? true,
      });
      print('✔️ Profile updated for user: $uid');
      return true;
    } catch (e) {
      print('❌ Failed to update profile: $e');
      return false;
    }
  }

  Future<bool> deleteAccount(BuildContext context) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
      print('✔️ Successfully deleted account for user: $uid');
      return true;
    } catch (e) {
      print('❌ Failed to delete account: $e');
      return false;
    }
  }

  String? validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Use a valid email address';
    }
    return null;
  }

  String? validatePhone(String phone) {
    final phoneRegex = RegExp(r'^(059|97259)\d{7}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Phone must start with 059 and be 10 digits';
    }
    return null;
  }

  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  }

  String? validateLocation(String location) {
    if (location.trim().isEmpty) {
      return 'Location cannot be empty';
    }
    return null;
  }
}