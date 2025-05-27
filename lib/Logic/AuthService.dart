
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a customer
  Future<String?> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  // Register a seller
  Future<String?> registerSeller({
    required String name,
    required String email,
    required String password,
    required String businessName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'businessName': businessName,
        'role': 'seller',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  // Login for both customers and sellers
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return 'Login failed: ${e.message}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
// Send password reset email
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-not-found':
          return 'No user found with this email.';
        default:
          return e.message ?? 'Error sending reset link';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Optional: Logout method
  Future<void> logout() async {
    await _auth.signOut();
  }
}