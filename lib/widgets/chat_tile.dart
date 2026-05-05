// SmartChat - Chat Tile Widget
//
// Displays a single chat room entry in the chat list.
// Shows avatar, name, last message preview, time, and unread count.

import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import 'user_avatar.dart';

class ChatTile extends StatelessWidget {
  /// The chat room data to display.
  final ChatRoomModel chatRoom;

  /// The current user's ID (to determine the "other" participant).
  final String currentUserId;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine display name based on chat type
    final displayName = _getDisplayName();
    final unreadCount = chatRoom.unreadCount[currentUserId] ?? 0;

    return ListTile(
      onTap: onTap,
      leading: UserAvatar(name: displayName, radius: 28),
      title: Text(
        displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chatRoom.lastMessage.isEmpty ? 'No messages yet' : chatRoom.lastMessage,
        style: theme.textTheme.bodySmall?.copyWith(
          color: unreadCount > 0
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Timestamp
          Text(
            AppUtils.formatChatTimestamp(chatRoom.lastMessageTime),
            style: theme.textTheme.labelSmall?.copyWith(
              color: unreadCount > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          // Unread badge
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Determines the display name based on chat type.
  String _getDisplayName() {
    if (chatRoom.type == AppConstants.chatTypeGroup) {
      return chatRoom.groupName ?? 'Group Chat';
    }
    if (chatRoom.type == AppConstants.chatTypeAI) {
      return 'AI Assistant';
    }
    // For one-to-one, show the other participant's name
    for (final entry in chatRoom.participantNames.entries) {
      if (entry.key != currentUserId) {
        return entry.value;
      }
    }
    return 'Chat';
  }
}
