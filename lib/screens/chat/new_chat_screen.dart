// SmartChat - New Chat Screen
//
// Allows users to search for other users and start a new conversation.
// Displays a list of all registered users filtered by search query.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Starts a chat with the selected user and navigates to it.
  Future<void> _startChat({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(currentUserProfileProvider).value;

    if (userId == null || userProfile == null) return;

    final chatRoomId = await ref
        .read(chatActionsProvider.notifier)
        .getOrCreateChat(
          currentUserId: userId,
          currentUserName: userProfile.displayName,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        );

    if (chatRoomId != null && mounted) {
      context.pushReplacement('/chat/$chatRoomId');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create chat. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // User list
          Expanded(
            child: allUsersAsync.when(
              loading: () => const LoadingWidget(message: 'Loading users...'),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Failed to load users',
                subtitle: error.toString(),
              ),
              data: (users) {
                // Filter by search query
                final filtered = _searchQuery.isEmpty
                    ? users
                    : users
                          .where(
                            (u) =>
                                u.displayName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                u.email.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No users found',
                    subtitle: 'Try a different search term',
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return ListTile(
                      leading: UserAvatar(
                        name: user.displayName,
                        photoURL: user.photoURL,
                        showOnlineStatus: true,
                        isOnline: user.isOnline,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => _startChat(
                        otherUserId: user.uid,
                        otherUserName: user.displayName,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
