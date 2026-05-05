// SmartChat - User Service
//
// Handles Firestore CRUD operations for user profiles.
// Provides streams for real-time user data updates.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Read Operations ──────────────────────────────────

  /// Returns a real-time stream of the user document for [userId].
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data()!);
          }
          return null;
        });
  }

  /// Fetches a single user by [userId] (one-time read).
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Returns all users except the current user [excludeUserId].
  /// Used for the "New Chat" user search screen.
  Future<List<UserModel>> getAllUsers({String? excludeUserId}) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('displayName')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != excludeUserId)
        .toList();
  }

  /// Searches users by display name (case-insensitive prefix match).
  Future<List<UserModel>> searchUsers({
    required String query,
    String? excludeUserId,
  }) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.trim().toLowerCase();

    // Firestore doesn't support case-insensitive search natively,
    // so we fetch all and filter client-side for small user bases.
    // For production at scale, use Algolia or Firebase Extensions.
    final allUsers = await getAllUsers(excludeUserId: excludeUserId);

    return allUsers
        .where(
          (user) =>
              user.displayName.toLowerCase().contains(normalizedQuery) ||
              user.email.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  // ─── Write Operations ─────────────────────────────────

  /// Updates the user's profile with the given fields.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoURL != null) updates['photoURL'] = photoURL;
    if (bio != null) updates['bio'] = bio;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    }
  }

  /// Updates the user's online/offline status.
  Future<void> setOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'isOnline': isOnline, 'lastSeen': Timestamp.now()});
  }

  /// Updates the user's FCM token for push notifications.
  Future<void> updateFcmToken({
    required String userId,
    required String token,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'fcmToken': token});
  }
}
