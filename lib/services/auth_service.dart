// SmartChat - Authentication Service
//
// Handles all Firebase Authentication operations including
// email/password sign-up, login, Google Sign-In, and sign-out.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Current User ─────────────────────────────────────

  /// Returns the currently signed-in [User], or null.
  User? get currentUser => _auth.currentUser;

  /// Returns the current user's UID, or null.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email / Password Registration ────────────────────

  /// Registers a new user with [email], [password], and [displayName].
  /// Creates a corresponding Firestore user document.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update display name in Auth profile
      await user.updateDisplayName(displayName.trim());

      // Create Firestore user document
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ─── Email / Password Login ───────────────────────────

  /// Signs in a user with [email] and [password].
  /// Updates the user's online status to true.
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Ensure the Firestore user document exists.
      // Using `.update()` fails if the document was deleted (common after DB wipes).
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
            'isOnline': true,
            'lastSeen': Timestamp.now(),
            // Keep Firestore profile email in sync with Firebase Auth.
            'email': user.email ?? email,
          }, SetOptions(merge: true));

      // Fetch and return the user model
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        // Re-create user document if it was deleted
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName ?? email.split('@').first,
          photoURL: user.photoURL,
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());
        return userModel;
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ─── Google Login ──────────────────────────────────────────

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' : null,
  );

  /// Signs in a user with Google.
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted by user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Ensure the Firestore user document exists.
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
            'isOnline': true,
            'lastSeen': Timestamp.now(),
            'email': user.email ?? googleUser.email,
          }, SetOptions(merge: true));

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? googleUser.email,
          displayName: user.displayName ?? googleUser.displayName ?? googleUser.email.split('@').first,
          photoURL: user.photoURL ?? googleUser.photoUrl,
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());
        return userModel;
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ─── Sign Out ─────────────────────────────────────────

  /// Signs out the current user and sets their status to offline.
  Future<void> signOut() async {
    try {
      final uid = currentUserId;
      if (uid != null) {
        await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
          'isOnline': false,
          'lastSeen': Timestamp.now(),
        }, SetOptions(merge: true));
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // ─── Password Reset ──────────────────────────────────

  /// Sends a password reset email to [email].
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ─── Password Update ─────────────────────────────────

  /// Updates the current user's password.
  /// Requires [currentPassword] for re-authentication and [newPassword] for the new password.
  /// Throws [FirebaseAuthException] on failure.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      if (user.email == null) {
        throw Exception('User email not found.');
      }

      // Re-authenticate user before password change
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // ─── Email Update ────────────────────────────────────

  /// Updates the current user's email.
  /// Requires [currentPassword] for re-authentication and [newEmail] for the new email.
  /// Also updates the email field in the corresponding Firestore user document.
  /// Throws [FirebaseAuthException] on failure.
  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final currentEmail = user.email;
      if (currentEmail == null || currentEmail.trim().isEmpty) {
        throw Exception('User email not found.');
      }

      final trimmedNewEmail = newEmail.trim();

      // Re-authenticate user before email change
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Firebase recommended approach:
      // this sends a verification link and applies the email change after the user confirms it.
      await user.verifyBeforeUpdateEmail(trimmedNewEmail);

      // Note: We do NOT update Firestore immediately here.
      // The user's actual login email will only change after they verify it.
      // Firestore should ideally be updated securely via a Cloud Function,
      // or at least wait until the user successfully signs in with the new email.
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  // ─── Account Deletion ──────────────────────────────────────

  /// Deletes the current user's account from Firebase Auth and their document from Firestore.
  /// Requires re-authentication with [password].
  /// Throws [FirebaseAuthException] on failure.
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final email = user.email;
      if (email == null || email.trim().isEmpty) {
        throw Exception('User email not found.');
      }

      // Re-authenticate user before deletion
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;

      // Delete Firestore user document
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .delete();
      } catch (e) {
        // If Firestore rules prevent client-side deletion, we still want to delete the Auth account.
        debugPrint('Failed to delete Firestore user document: $e');
      }

      // Finally, delete the Firebase auth account
      await user.delete();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
