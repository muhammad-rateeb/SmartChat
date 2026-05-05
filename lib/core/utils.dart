// SmartChat - Core Utilities
//
// Helper functions used throughout the application.
// Provides date formatting, validation, and common operations.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._(); // Prevent instantiation

  // ─── Date / Time Formatting ───────────────────────────

  /// Formats a [DateTime] to a user-friendly chat timestamp.
  /// Shows "Just now" for < 1 min, "X min ago" for < 1 hour,
  /// time for today, "Yesterday", or the full date.
  static String formatChatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (isSameDay(dateTime, now)) return DateFormat('h:mm a').format(dateTime);
    if (isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(dateTime);
  }

  /// Formats a [DateTime] to a message time string (e.g., "2:30 PM").
  static String formatMessageTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Formats a [DateTime] to a date and day string (e.g., "Monday, Oct 12, 2023").
  static String formatMessageDateAndDay(DateTime dateTime) {
    final now = DateTime.now();
    if (isSameDay(dateTime, now)) return 'Today';
    if (isSameDay(dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }

  /// Checks if two [DateTime] objects represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─── Validation ───────────────────────────────────────

  /// Validates an email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a password (minimum 6 characters).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates a display name (not empty, 2-50 chars).
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  // ─── Chat Helpers ─────────────────────────────────────

  /// Generates a deterministic chat room ID for two users.
  /// Ensures the same ID regardless of who initiates the chat.
  static String generateChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Returns initials from a display name (e.g., "John Doe" → "JD").
  static String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ─── UI Helpers ───────────────────────────────────────

  /// Shows a [SnackBar] with the given message.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
