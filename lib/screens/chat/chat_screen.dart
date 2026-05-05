// SmartChat - Chat Screen
//
// Individual chat conversation screen. Shows real-time messages
// with a text input bar for sending messages.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/storage_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  /// The chat room ID to display.
  final String chatRoomId;

  const ChatScreen({super.key, required this.chatRoomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening the chat
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      final defaultDir = await getApplicationDocumentsDirectory();
      _audioPath =
          '${defaultDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: _audioPath!,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required to send voice messages.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _stopRecordingAndSend() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if (path != null && path.isNotEmpty) {
      final userId = ref.read(currentUserIdProvider);
      final userProfile = ref.read(currentUserProfileProvider).value;

      if (userId == null || userProfile == null) return;

      try {
        // Show loading or something, but we'll just upload background
        final downloadUrl = await StorageService().uploadAudioMessage(
          chatRoomId: widget.chatRoomId,
          filePath: path,
        );

        await ref
            .read(chatActionsProvider.notifier)
            .sendMessage(
              chatRoomId: widget.chatRoomId,
              senderId: userId,
              senderName: userProfile.displayName,
              text: '', // Audio messages have no text
              type: AppConstants.messageTypeAudio,
              audioURL: downloadUrl,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send audio message: $e')),
          );
        }
      }
    }
  }

  /// Marks all messages as read for the current user.
  void _markAsRead() {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      ref
          .read(chatActionsProvider.notifier)
          .markAsRead(chatRoomId: widget.chatRoomId, userId: userId);
    }
  }

  void _maybeMarkAsRead(List<MessageModel> messages, String? userId) {
    if (userId == null) return;

    // Only mark as read if there exists at least one message not yet read by
    // the current user.
    final hasUnread = messages.any(
      (m) => !m.readBy.contains(userId) && m.senderId != userId,
    );
    if (hasUnread) {
      // Avoid calling Firestore directly during build.
      Future.microtask(_markAsRead);
    }
  }

  /// Sends the current message text.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(currentUserProfileProvider).value;

    if (userId == null || userProfile == null) return;

    _messageController.clear();

    await ref
        .read(chatActionsProvider.notifier)
        .sendMessage(
          chatRoomId: widget.chatRoomId,
          senderId: userId,
          senderName: userProfile.displayName,
          text: text,
        );
  }

  /// Prompts the user and deletes the chat room.
  Future<void> _deleteChat(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this entire chat room? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        await ref
            .read(chatActionsProvider.notifier)
            .deleteChat(chatRoomId: widget.chatRoomId);
        if (context.mounted) {
          // Go back to the previous screen since the chat is now deleted
          context.pop();
        }
      }
    }
  }

  void _showGroupInfo(BuildContext context, ChatRoomModel room) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final participants = room.participantNames.entries.toList();
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    '${room.groupName ?? 'Group'} Info',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    '${participants.length} Members',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final member = participants[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.value.isNotEmpty
                                ? member.value[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(member.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));
    final chatRooms = ref.watch(chatRoomsProvider);

    // Show error snackbar when message send fails
    ref.listen<ChatActionState>(chatActionsProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    // Get chat room info for the app bar title
    final chatRoom = chatRooms.whenData((rooms) {
      try {
        return rooms.firstWhere((r) => r.id == widget.chatRoomId);
      } catch (_) {
        return null;
      }
    });

    // Determine the display title
    String title = 'Chat';
    chatRoom.whenData((room) {
      if (room != null) {
        if (room.type == AppConstants.chatTypeGroup) {
          title = room.groupName ?? 'Group Chat';
        } else {
          for (final entry in room.participantNames.entries) {
            if (entry.key != userId) {
              title = entry.value;
              break;
            }
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (chatRoom.value?.type == AppConstants.chatTypeGroup)
            IconButton(
              icon: const Icon(Icons.group_outlined),
              tooltip: 'Group Info',
              onPressed: () => _showGroupInfo(context, chatRoom.value!),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Chat',
            onPressed: () => _deleteChat(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const LoadingWidget(message: 'Loading messages...'),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Failed to load messages',
                subtitle: error.toString(),
              ),
              data: (messages) {
                _maybeMarkAsRead(messages, userId);

                if (messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.message_outlined,
                    title: 'No messages yet',
                    subtitle: 'Send a message to start the conversation',
                  );
                }

                final room = chatRoom.value;
                final participants = room?.participants ?? const <String>[];
                final isGroup = room?.type == AppConstants.chatTypeGroup;
                String? otherUserId;
                if (!isGroup && participants.isNotEmpty && userId != null) {
                  for (final pid in participants) {
                    if (pid != userId) {
                      otherUserId = pid;
                      break;
                    }
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Newest messages at the bottom
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userId;

                    final isSeen = isMe
                        ? _computeIsSeen(
                            message: message,
                            isGroup: isGroup,
                            participants: participants,
                            otherUserId: otherUserId,
                          )
                        : false;

                    bool showDateSeparator = false;
                    if (index == messages.length - 1) {
                      showDateSeparator = true;
                    } else {
                      final prevMessage = messages[index + 1];
                      if (!AppUtils.isSameDay(
                        message.timestamp,
                        prevMessage.timestamp,
                      )) {
                        showDateSeparator = true;
                      }
                    }

                    Widget bubble = MessageBubble(
                      message: message,
                      isMe: isMe,
                      showSenderName:
                          chatRoom.value?.type == AppConstants.chatTypeGroup,
                      isSeen: isSeen,
                      onLongPress: isMe
                          ? () => _showMessageActions(message)
                          : null,
                    );

                    if (showDateSeparator) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppUtils.formatMessageDateAndDay(
                                  message.timestamp,
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ),
                          bubble,
                        ],
                      );
                    }

                    return bubble;
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send/Voice button
                  GestureDetector(
                    onTap: _sendMessage,
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecordingAndSend(),
                    onLongPressCancel: () => _stopRecordingAndSend(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.send,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for deleting a message.
  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(chatActionsProvider.notifier)
                  .deleteMessage(
                    chatRoomId: widget.chatRoomId,
                    messageId: messageId,
                  );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _computeIsSeen({
    required MessageModel message,
    required bool isGroup,
    required List<String> participants,
    required String? otherUserId,
  }) {
    if (message.isDeleted) return false;
    if (participants.isEmpty) {
      return message.readBy.length > 1;
    }

    if (isGroup) {
      // Consider "seen" when all participants have read.
      return participants.every((id) => message.readBy.contains(id));
    }

    if (otherUserId == null) return message.readBy.length > 1;
    return message.readBy.contains(otherUserId);
  }

  void _showMessageActions(MessageModel message) {
    final canEdit =
        !message.isDeleted &&
        message.type == 'text' &&
        (message.imageURL == null || message.imageURL!.isEmpty);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit message'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete message'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(message.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(MessageModel message) {
    final controller = TextEditingController(text: message.text);
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Update your message...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isEmpty) return;

              ref
                  .read(chatActionsProvider.notifier)
                  .editMessage(
                    chatRoomId: widget.chatRoomId,
                    messageId: message.id,
                    newText: newText,
                  );
              Navigator.pop(context);
            },
            child: Text('Save', style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}
