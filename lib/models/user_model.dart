// SmartChat - User Model
//
// Represents a user in the SmartChat application.
// Maps directly to the `users` Firestore collection.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  /// Firebase Auth UID — primary key.
  final String uid;

  /// User's email address.
  final String email;

  /// Display name shown in chats and profile.
  final String displayName;

  /// URL to the user's profile photo (nullable).
  final String? photoURL;

  /// Whether the user is currently online.
  final bool isOnline;

  /// The last time the user was active.
  final DateTime lastSeen;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Firebase Cloud Messaging token for push notifications.
  final String? fcmToken;

  /// Short bio / status message.
  final String bio;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    this.fcmToken,
    this.bio = '',
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Unknown',
      photoURL: map['photoURL'] as String?,
      isOnline: map['isOnline'] as bool? ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: map['fcmToken'] as String?,
      bio: map['bio'] as String? ?? '',
    );
  }

  /// Converts this [UserModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
      'bio': bio,
    };
  }

  /// Creates a copy of this [UserModel] with the given fields replaced.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? fcmToken,
    String? bio,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
