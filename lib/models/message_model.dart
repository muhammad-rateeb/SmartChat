// SmartChat - Message Model
//
// Represents a single message within a chat room.
// Maps to the `messages` sub-collection under `chatRooms`.

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  /// Unique message identifier.
  final String id;

  /// UID of the sender.
  final String senderId;

  /// Display name of the sender (denormalized for performance).
  final String senderName;

  /// Text content of the message.
  final String text;

  /// URL to an attached image (nullable).
  final String? imageURL;

  /// URL to an attached audio recording (nullable).
  final String? audioURL;

  /// Message type: "text", "image", "audio", or "ai_response".
  final String type;

  /// When the message was sent.
  final DateTime timestamp;

  /// List of user IDs who have read this message.
  final List<String> readBy;

  /// When the message was last edited (null if never edited).
  final DateTime? editedAt;

  /// Whether this message has been soft-deleted.
  final bool isDeleted;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageURL,
    this.audioURL,
    this.type = 'text',
    required this.timestamp,
    this.readBy = const [],
    this.editedAt,
    this.isDeleted = false,
  });

  /// Creates a [MessageModel] from a Firestore document snapshot.
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Unknown',
      text: map['text'] as String? ?? '',
      imageURL: map['imageURL'] as String?,
      audioURL: map['audioURL'] as String?,
      type: map['type'] as String? ?? 'text',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? []),
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  /// Converts this [MessageModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageURL': imageURL,
      'audioURL': audioURL,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),
      'isDeleted': isDeleted,
    };
  }

  /// Creates a copy with the given fields replaced.
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    String? imageURL,
    String? audioURL,
    String? type,
    DateTime? timestamp,
    List<String>? readBy,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      imageURL: imageURL ?? this.imageURL,
      audioURL: audioURL ?? this.audioURL,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() =>
      'MessageModel(id: $id, senderId: $senderId, text: ${text.length > 30 ? '${text.substring(0, 30)}...' : text})';
}
