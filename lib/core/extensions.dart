// SmartChat - Dart Extension Methods
//
// Convenient extensions on built-in Dart/Flutter types
// to reduce boilerplate and improve readability.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Extensions on [String] for common chat operations.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncates the string to [maxLength] and appends "..." if needed.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Extensions on [DateTime] for Firestore conversion.
extension DateTimeExtensions on DateTime {
  /// Converts to a Firestore [Timestamp].
  Timestamp toTimestamp() => Timestamp.fromDate(this);
}

/// Extensions on [Timestamp] for DateTime conversion.
extension TimestampExtensions on Timestamp {
  /// Converts to a Dart [DateTime].
  DateTime toDateTime() => toDate();
}
