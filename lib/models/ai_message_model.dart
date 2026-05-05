// SmartChat - AI Message Model
//
// Represents a single message in an AI conversation.
// Maps to the `aiChats/{userId}/messages` Firestore path.

import 'package:cloud_firestore/cloud_firestore.dart';

class AiMessageModel {
  /// Unique message identifier.
  final String id;

  /// Role: "user" or "assistant".
  final String role;

  /// Text content of the message.
  final String content;

  /// When the message was sent/received.
  final DateTime timestamp;

  /// Whether this message represents an error response.
  final bool isError;

  const AiMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
  });

  /// Whether this message was sent by the user.
  bool get isUser => role == 'user';

  /// Whether this message was sent by the AI assistant.
  bool get isAssistant => role == 'assistant';

  /// Creates an [AiMessageModel] from a Firestore document snapshot.
  factory AiMessageModel.fromMap(Map<String, dynamic> map) {
    return AiMessageModel(
      id: map['id'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      content: map['content'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isError: map['isError'] as bool? ?? false,
    );
  }

  /// Converts this [AiMessageModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isError': isError,
    };
  }

  @override
  String toString() =>
      'AiMessageModel(role: $role, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content})';
}
