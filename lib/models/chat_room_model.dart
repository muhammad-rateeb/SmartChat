// SmartChat - ChatRoom Model
//
// Represents a chat room (one-to-one, group, or AI).
// Maps directly to the `chatRooms` Firestore collection.

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  /// Unique chat room identifier.
  final String id;

  /// Type of chat room: "oneToOne", "group", or "ai".
  final String type;

  /// List of user IDs who are participants.
  final List<String> participants;

  /// Map of userId → displayName for quick lookups.
  final Map<String, String> participantNames;

  /// Preview text of the last message sent.
  final String lastMessage;

  /// Timestamp of the last message.
  final DateTime lastMessageTime;

  /// UID of the last message sender.
  final String lastMessageSenderId;

  /// Group chat name (null for one-to-one).
  final String? groupName;

  /// Group photo URL (null for one-to-one).
  final String? groupPhoto;

  /// UID of the user who created this chat room.
  final String createdBy;

  /// When the chat room was created.
  final DateTime createdAt;

  /// Map of userId → unread message count.
  final Map<String, int> unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.type,
    required this.participants,
    required this.participantNames,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.groupName,
    this.groupPhoto,
    required this.createdBy,
    required this.createdAt,
    this.unreadCount = const {},
  });

  /// Creates a [ChatRoomModel] from a Firestore document snapshot.
  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? 'oneToOne',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: map['lastMessageSenderId'] as String? ?? '',
      groupName: map['groupName'] as String?,
      groupPhoto: map['groupPhoto'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(
        (map['unreadCount'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toInt()),
            ) ??
            {},
      ),
    );
  }

  /// Converts this [ChatRoomModel] to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'unreadCount': unreadCount,
    };
  }

  /// Creates a copy with the given fields replaced.
  ChatRoomModel copyWith({
    String? id,
    String? type,
    List<String>? participants,
    Map<String, String>? participantNames,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    String? groupName,
    String? groupPhoto,
    String? createdBy,
    DateTime? createdAt,
    Map<String, int>? unreadCount,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      groupName: groupName ?? this.groupName,
      groupPhoto: groupPhoto ?? this.groupPhoto,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() => 'ChatRoomModel(id: $id, type: $type)';
}
