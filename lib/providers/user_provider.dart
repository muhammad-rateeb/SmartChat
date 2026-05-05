// SmartChat - User Provider
//
// Riverpod providers for user profile data and search.
// Provides real-time user streams and profile update actions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

/// Singleton provider for the [UserService].
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Stream provider for the current user's profile data.
/// Automatically updates when the profile is modified.
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(userId);
});

/// Family provider for any user's profile by UID.
/// Usage: ref.watch(userProfileProvider('someUserId'))
final userProfileProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(userId);
});

/// Future provider for searching users by name/email.
/// Usage: ref.watch(searchUsersProvider('query'))
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((
  ref,
  query,
) async {
  final userId = ref.watch(currentUserIdProvider);
  final userService = ref.watch(userServiceProvider);
  return userService.searchUsers(query: query, excludeUserId: userId);
});

/// Future provider for fetching all users (for New Chat screen).
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final userService = ref.watch(userServiceProvider);
  return userService.getAllUsers(excludeUserId: userId);
});
