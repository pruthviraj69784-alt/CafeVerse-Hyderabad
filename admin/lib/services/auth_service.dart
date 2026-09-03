import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role, // 'customer' or 'admin'
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      throw 'No user profile found for this account. Please register or contact support.';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Get user from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  // Stream of user data
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to logout: $e';
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Failed to send reset email: $e';
    }
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: oldPassword,
          ),
        );
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw 'Failed to change password: $e';
    }
  }
}
