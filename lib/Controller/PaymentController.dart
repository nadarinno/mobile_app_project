import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void onCreditCardModelChange({
    required String cardNumber,
    required String expiryDate,
    required String cardHolderName,
    required String cvvCode,
    required bool isCvvFocused,
  }) {
    this.cardNumber = cardNumber;
    this.expiryDate = expiryDate;
    this.cardHolderName = cardHolderName;
    this.cvvCode = cvvCode;
    this.isCvvFocused = isCvvFocused;
  }

  Future<void> saveCardToFirestore({
    required String cardNumber,
    required String expiryDate,
    required String cardHolder,
    required String cvv,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No authenticated user found');
      throw Exception('User must be authenticated to save payment');
    }

    try {
      print('Attempting to save card to Firestore for user: $userId');
      print('Data: cardNumber=$cardNumber, expiryDate=$expiryDate, cardHolder=$cardHolder, cvv=$cvv');

      // Ensure the user document exists
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({}, SetOptions(merge: true)); // Creates user doc if it doesn't exist

      // Add payment to the payments collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payments')
          .add({
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardHolder': cardHolder,
        'cvv': cvv,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Payment successfully saved to Firestore for user: $userId');
    } catch (e, stackTrace) {
      print('Error saving card to Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Allow UI to handle the error
    }
  }

  Future<void> submitPaymentForm(BuildContext context, VoidCallback onSuccess) async {
    print('Submitting payment form...');
    print('Current form data: cardNumber=$cardNumber, expiryDate=$expiryDate, cardHolderName=$cardHolderName, cvvCode=$cvvCode');

    if (formKey.currentState == null) {
      print('Form key is null, cannot validate');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form is not initialized properly')),
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      print('Form validation passed');
      isLoading.value = true;
      try {
        await saveCardToFirestore(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolder: cardHolderName,
          cvv: cvvCode,
        );
        isLoading.value = false;
        print('Form submission successful');
        onSuccess();
      } catch (e) {
        isLoading.value = false;
        print('Form submission failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save payment: $e')),
        );
      }
    } else {
      print('Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please correct form errors')),
      );
    }
  }
}