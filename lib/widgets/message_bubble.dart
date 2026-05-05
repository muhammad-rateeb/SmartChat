// SmartChat - Message Bubble Widget
//
// Displays a single chat message in a styled bubble.
// Aligns sent messages to the right and received to the left.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message_model.dart';
import '../core/utils.dart';
import '../core/constants.dart';
import 'audio_player_bubble.dart';

class MessageBubble extends StatelessWidget {
  /// The message data to display.
  final MessageModel message;

  /// Whether this message was sent by the current user.
  final bool isMe;

  /// Whether to show the sender name (useful in group chats).
  final bool showSenderName;

  /// Callback when the message is long-pressed (for delete, etc.).
  final VoidCallback? onLongPress;

  /// Whether the message has been seen (read) by intended recipients.
  /// Only used for outgoing (isMe) messages.
  final bool isSeen;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSenderName = false,
    this.onLongPress,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Deleted message styling
    if (message.isDeleted) {
      return _buildDeletedBubble(theme);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: isMe ? 64 : 8,
            right: isMe ? 8 : 64,
            top: 4,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Sender name (for group chats)
              if (showSenderName && !isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Image message
              if (message.type == AppConstants.messageTypeImage &&
                  message.imageURL != null &&
                  message.imageURL!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: message.imageURL!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Icon(Icons.error),
                    ),
                  ),
                ),

              // Audio message
              if (message.type == AppConstants.messageTypeAudio &&
                  message.audioURL != null &&
                  message.audioURL!.isNotEmpty)
                AudioPlayerBubble(audioUrl: message.audioURL!, isMe: isMe),

              // Text content
              if (message.type == AppConstants.messageTypeText &&
                  message.text.isNotEmpty)
                Padding(
                  padding: message.imageURL != null || message.audioURL != null
                      ? const EdgeInsets.only(top: 8)
                      : EdgeInsets.zero,
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),

              // Timestamp
              const SizedBox(height: 4),
              _buildMetaRow(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(ThemeData theme) {
    final baseMetaColor = isMe
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    // Colorless vs colorful ticks as requested:
    // - Sent (single tick): low-alpha ("colorless")
    // - Seen (double tick): secondary color ("colorful")
    final sentTickColor = isMe
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.55)
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final seenTickColor = theme.colorScheme.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppUtils.formatMessageTime(message.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: baseMetaColor,
            fontSize: 10,
          ),
        ),
        if (message.editedAt != null) ...[
          const SizedBox(width: 6),
          Text(
            'edited',
            style: theme.textTheme.labelSmall?.copyWith(
              color: baseMetaColor,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (isMe) ...[
          const SizedBox(width: 6),
          Icon(
            isSeen ? Icons.done_all : Icons.done,
            size: 14,
            color: isSeen ? seenTickColor : sentTickColor,
          ),
        ],
      ],
    );
  }

  /// Builds the bubble for a deleted message.
  Widget _buildDeletedBubble(ThemeData theme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              'This message was deleted',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
