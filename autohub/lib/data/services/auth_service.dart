import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: user.uid,
          email: email,
          username: username,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Get user data from Firestore
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }
}
