// SmartChat - Auth Provider
//
// Riverpod providers for authentication state management.
// Provides auth state streams, login/register/logout actions.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Singleton provider for the [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream provider that listens to Firebase Auth state changes.
/// Emits the current [User] or null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the currently signed-in user's UID.
/// Returns null if not authenticated.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user?.uid, orElse: () => null);
});

/// State notifier that manages auth operations and loading state.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// ─── Auth State ───────────────────────────────────────────

/// Represents the current authentication UI state.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  AuthState copyWith({bool? isLoading, String? errorMessage, UserModel? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

// ─── Auth Notifier ────────────────────────────────────────

/// Manages authentication actions and updates [AuthState].
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Registers a new user with email, password, and display name.
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Registration failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Logs in a user with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Login failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Updates the current user's password.
  /// Returns true on success, false on failure.
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Current password is incorrect.';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak. Use at least 6 characters.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please log out and log in again before changing your password.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to update password.';
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Updates the current user's email.
  /// Returns true on success, false on failure.
  Future<bool> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.updateEmail(
        currentPassword: currentPassword,
        newEmail: newEmail,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Current password is incorrect.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'email-already-in-use':
          errorMessage = 'That email is already in use.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please log out and log in again before changing your email.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to update email.';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Deletes the current user's account.
  /// Returns true on success, false on failure.
  Future<bool> deleteAccount({required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.deleteAccount(password: password);
      // Wait for authStateProvider to pick up the sign-out automatically.
      state = const AuthState();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Password is incorrect.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please log out and log in again before deleting your account.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to delete account.';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
