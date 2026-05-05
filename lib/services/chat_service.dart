// SmartChat - Chat Service
//
// Handles all Firestore operations related to chat rooms and messages.
// Provides real-time streams for message updates and chat list.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../core/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ─── Chat Room Operations ─────────────────────────────

  /// Returns a real-time stream of chat rooms for user [userId].
  /// Ordered by last message time (newest first).
  Stream<List<ChatRoomModel>> getChatRoomsStream(String userId) {
    return _firestore
        .collection(AppConstants.chatRoomsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoomModel.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Creates or retrieves a one-to-one chat room between two users.
  /// Returns the chat room ID.
  Future<String> getOrCreateOneToOneChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    // Generate deterministic ID for the pair
    final sortedIds = [currentUserId, otherUserId]..sort();
    final chatRoomId = '${sortedIds[0]}_${sortedIds[1]}';

    final doc = await _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .get();

    if (!doc.exists) {
      // Create new chat room
      final chatRoom = ChatRoomModel(
        id: chatRoomId,
        type: AppConstants.chatTypeOneToOne,
        participants: [currentUserId, otherUserId],
        participantNames: {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        createdBy: currentUserId,
        createdAt: DateTime.now(),
        unreadCount: {currentUserId: 0, otherUserId: 0},
      );

      await _firestore
          .collection(AppConstants.chatRoomsCollection)
          .doc(chatRoomId)
          .set(chatRoom.toMap());
    }

    return chatRoomId;
  }

  /// Creates a new group chat room.
  /// Returns the chat room ID.
  Future<String> createGroupChat({
    required String creatorId,
    required String groupName,
    required List<String> participantIds,
    required Map<String, String> participantNames,
  }) async {
    final chatRoomId = _uuid.v4();

    final unreadCount = <String, int>{};
    for (final id in participantIds) {
      unreadCount[id] = 0;
    }

    final chatRoom = ChatRoomModel(
      id: chatRoomId,
      type: AppConstants.chatTypeGroup,
      participants: participantIds,
      participantNames: participantNames,
      lastMessage: '${participantNames[creatorId]} created the group',
      lastMessageTime: DateTime.now(),
      lastMessageSenderId: creatorId,
      groupName: groupName,
      createdBy: creatorId,
      createdAt: DateTime.now(),
      unreadCount: unreadCount,
    );

    await _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .set(chatRoom.toMap());

    return chatRoomId;
  }

  // ─── Message Operations ───────────────────────────────

  /// Returns a real-time stream of messages for chat room [chatRoomId].
  /// Ordered by timestamp (newest first) for reverse list display.
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .collection(AppConstants.messagesSubCollection)
        .orderBy('timestamp', descending: true)
        .limit(AppConstants.messagePageSize)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Sends a text or media message in the specified chat room.
  /// Updates the chat room's last message metadata.
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
    String? imageURL,
    String? audioURL,
  }) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      imageURL: imageURL,
      audioURL: audioURL,
      type: type,
      timestamp: now,
      readBy: [senderId],
    );

    // Use a batch write for atomicity
    final batch = _firestore.batch();

    // Add the message
    final messageRef = _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId);
    batch.set(messageRef, message.toMap());

    // Update chat room metadata and increment unread counts
    final chatRoomRef = _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId);

    // Get chat room to find other participants
    final chatRoomDoc = await chatRoomRef.get();
    final participants = List<String>.from(
      (chatRoomDoc.data()?['participants'] as List?) ?? [],
    );

    // Build update map with unread increments for other participants
    String displayLastMessage = text;
    if (type == 'image') {
      displayLastMessage = '📷 Image';
    } else if (type == 'audio') {
      displayLastMessage = '🎤 Voice Message';
    }

    final updateData = <String, dynamic>{
      'lastMessage': displayLastMessage,
      'lastMessageTime': Timestamp.fromDate(now),
      'lastMessageSenderId': senderId,
    };
    for (final participantId in participants) {
      if (participantId != senderId) {
        updateData['unreadCount.$participantId'] = FieldValue.increment(1);
      }
    }

    batch.update(chatRoomRef, updateData);

    await batch.commit();
  }

  /// Marks all messages in a chat room as read by [userId].
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String userId,
  }) async {
    // Reset unread count for this user
    final chatRoomRef = _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId);

    // Fetch a page of most recent messages and mark as read.
    // Firestore does not support "where readBy does NOT contain userId", so we
    // filter client-side and only update docs that actually need it.
    final messagesQuery = await chatRoomRef
        .collection(AppConstants.messagesSubCollection)
        .orderBy('timestamp', descending: true)
        .limit(AppConstants.messagePageSize)
        .get();

    final batch = _firestore.batch();
    batch.update(chatRoomRef, {'unreadCount.$userId': 0});

    for (final doc in messagesQuery.docs) {
      final data = doc.data();
      final readBy = List<String>.from(data['readBy'] ?? const <String>[]);
      if (!readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }

    await batch.commit();
  }

  /// Soft-deletes a message by setting [isDeleted] to true.
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .update({'isDeleted': true, 'text': 'This message was deleted'});
  }

  /// Edits a text message.
  /// This does not currently update the chat room's last message preview.
  Future<void> editMessage({
    required String chatRoomId,
    required String messageId,
    required String newText,
  }) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    await _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .update({'text': trimmed, 'editedAt': Timestamp.now()});
  }

  /// Deletes an entire chat room.
  /// Note: This deletes the main chat room document. To properly delete all messages
  /// in production, a Cloud Function should be triggered or a batch deletion logic used.
  Future<void> deleteChat({required String chatRoomId}) async {
    await _firestore
        .collection(AppConstants.chatRoomsCollection)
        .doc(chatRoomId)
        .delete();
  }
}
