import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? get currentUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Register
  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      email = email.trim().toLowerCase();
      name = name.trim();

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return 'Please fill all fields';
      }

      if (!_isValidEmail(email)) {
        return 'Please enter a valid email';
      }

      if (password.length < 6) {
        return 'Password must be at least 6 characters';
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        default:
          return e.message ?? 'Registration failed';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      email = email.trim().toLowerCase();

      if (email.isEmpty || password.isEmpty) {
        return 'Please fill all fields';
      }

      if (!_isValidEmail(email)) {
        return 'Please enter a valid email';
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'invalid-email':
          return 'Invalid email';
        case 'user-disabled':
          return 'This account has been disabled';
        default:
          return e.message ?? 'Login failed';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> logout() async => _auth.signOut();

  // Fetch user profile
  Future<User?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  // Update profile
  Future<String?> updateUserProfile({
    required String uid,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name.trim(),
      });
      return null;
    } catch (_) {
      return 'Failed to update profile';
    }
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }
}
