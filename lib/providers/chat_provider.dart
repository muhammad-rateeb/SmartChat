// SmartChat - Chat Provider
//
// Riverpod providers for chat room and message state management.
// Provides real-time streams and action methods for messaging.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import 'auth_provider.dart';

/// Singleton provider for the [ChatService].
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// Stream provider for all chat rooms of the current user.
/// Automatically updates when new chats are created or messages arrive.
final chatRoomsProvider = StreamProvider.autoDispose<List<ChatRoomModel>>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatRoomsStream(userId);
});

/// Family provider for messages in a specific chat room.
/// Usage: ref.watch(messagesProvider('chatRoomId'))
final messagesProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, chatRoomId) {
      // Tie the message stream lifecycle to the authenticated user.
      // This prevents leaking/caching message streams across logout/login.
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return const Stream.empty();

      final chatService = ref.watch(chatServiceProvider);
      return chatService.getMessagesStream(chatRoomId);
    });

/// State notifier for chat actions (sending messages, creating chats).
final chatActionsProvider =
    StateNotifierProvider<ChatActionsNotifier, ChatActionState>((ref) {
      final chatService = ref.watch(chatServiceProvider);
      return ChatActionsNotifier(chatService);
    });

// ─── Chat Action State ──────────────────────────────────

/// Represents the state of a chat action (sending, creating).
class ChatActionState {
  final bool isSending;
  final String? errorMessage;

  const ChatActionState({this.isSending = false, this.errorMessage});

  ChatActionState copyWith({bool? isSending, String? errorMessage}) {
    return ChatActionState(
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

// ─── Chat Actions Notifier ──────────────────────────────

/// Manages chat actions and provides methods for sending messages
/// and creating chat rooms.
class ChatActionsNotifier extends StateNotifier<ChatActionState> {
  final ChatService _chatService;

  ChatActionsNotifier(this._chatService) : super(const ChatActionState());

  /// Sends a text or media message in the specified chat room.
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
    String? audioURL,
    String? imageURL,
  }) async {
    if (text.trim().isEmpty && audioURL == null && imageURL == null) return;

    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        text: text.trim(),
        type: type,
        audioURL: audioURL,
        imageURL: imageURL,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Failed to send message: $e',
      );
    }
  }

  /// Creates or retrieves a one-to-one chat room.
  Future<String?> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      return await _chatService.getOrCreateOneToOneChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create chat: $e');
      return null;
    }
  }

  /// Marks all messages in a chat room as read.
  Future<void> markAsRead({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      await _chatService.markMessagesAsRead(
        chatRoomId: chatRoomId,
        userId: userId,
      );
    } catch (_) {
      // Silent failure for read receipts
    }
  }

  /// Deletes a message.
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    try {
      await _chatService.deleteMessage(
        chatRoomId: chatRoomId,
        messageId: messageId,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete message: $e');
    }
  }

  /// Edits a text message.
  Future<void> editMessage({
    required String chatRoomId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await _chatService.editMessage(
        chatRoomId: chatRoomId,
        messageId: messageId,
        newText: newText,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to edit message: $e');
    }
  }

  /// Creates a new group chat and returns its chat room ID.
  Future<String?> createGroupChat({
    required String creatorId,
    required String groupName,
    required List<String> participantIds,
    required Map<String, String> participantNames,
  }) async {
    try {
      return await _chatService.createGroupChat(
        creatorId: creatorId,
        groupName: groupName,
        participantIds: participantIds,
        participantNames: participantNames,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create group: $e');
      return null;
    }
  }

  /// Deletes an entire chat room.
  Future<void> deleteChat({required String chatRoomId}) async {
    try {
      await _chatService.deleteChat(chatRoomId: chatRoomId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete chat: $e');
    }
  }
}
