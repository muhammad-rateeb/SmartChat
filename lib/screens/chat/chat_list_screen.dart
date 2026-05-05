// SmartChat - Chat List Screen
//
// Displays all conversations for the current user.
// Shows real-time updates as new messages arrive.
// Provides access to start new chats.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartChat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search/new chat screen
              context.push('/new-chat');
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'New group',
            onPressed: () => context.push('/new-group'),
          ),
        ],
      ),
      body: chatRoomsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading chats...'),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          subtitle: error.toString(),
        ),
        data: (chatRooms) {
          if (chatRooms.isEmpty) {
            return EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Start a new chat to begin messaging',
              actionButton: FilledButton.icon(
                onPressed: () => context.push('/new-chat'),
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
              ),
            );
          }

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return ChatTile(
                chatRoom: chatRoom,
                currentUserId: userId ?? '',
                onTap: () {
                  context.push('/chat/${chatRoom.id}');
                },
              );
            },
          );
        },
      ),
      // FAB for new chat
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-chat'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
