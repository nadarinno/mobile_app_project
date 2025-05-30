import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

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

      final isAdmin = email.toLowerCase() == 'admin@example.com';
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'role': isAdmin ? 'admin' : 'customer',
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
      await userCredential.user?.updateDisplayName(email);
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

  // Login for all users and return status with role
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Fetch user role from Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role']?.toLowerCase() ?? 'customer';
        return {
          'status': 'success',
          'role': role,
        };
      } else {
        return {
          'status': 'error',
          'message': 'User data not found',
          'role': null,
        };
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code.toString()) {
        case 'user-not-found':
          return {
            'status': 'error',
            'message': 'No user found with this email.',
            'role': null,
          };
        case 'wrong-password':
          return {
            'status': 'error',
            'message': 'Incorrect password.',
            'role': null,
          };
        case 'invalid-email':
          return {
            'status': 'error',
            'message': 'The email address is invalid.',
            'role': null,
          };
        default:
          return {
            'status': 'error',
            'message': 'Login failed: ${e.message}',
            'role': null,
          };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
        'role': null,
      };
    }
  }

  // Send password reset email
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code.toString()) {
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-not-found':
          return 'No user found with this email.';
        default:
          return e.message ?? 'Error sending reset email';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> changePassword({required String newPassword}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'No user is currently signed in.';
      }
      await user.updatePassword(newPassword);
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return 'Please log in again to change your password.';
        case 'weak-password':
          return 'The new password is too weak.';
        default:
          return 'Password change failed: ${e.message}';
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

  // Logout method
  Future<void> logout() async {
    await _auth.signOut();
  }

}