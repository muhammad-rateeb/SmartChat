// SmartChat - New Group Chat Screen
//
// Allows users to create a group chat by selecting multiple users and
// specifying a group name.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/user_avatar.dart';

class NewGroupChatScreen extends ConsumerStatefulWidget {
  const NewGroupChatScreen({super.key});

  @override
  ConsumerState<NewGroupChatScreen> createState() => _NewGroupChatScreenState();
}

class _NewGroupChatScreenState extends ConsumerState<NewGroupChatScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();

  final Set<String> _selectedUserIds = <String>{};
  String _searchQuery = '';

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createGroup(List<UserModel> allUsers) async {
    final creatorId = ref.read(currentUserIdProvider);
    final creatorProfile = ref.read(currentUserProfileProvider).value;

    if (creatorId == null || creatorProfile == null) return;

    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name.')),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one user.')),
      );
      return;
    }

    // Participants = creator + selected users.
    final participantIds = <String>{creatorId, ..._selectedUserIds}.toList();

    final participantNames = <String, String>{
      creatorId: creatorProfile.displayName,
    };

    for (final u in allUsers) {
      if (_selectedUserIds.contains(u.uid)) {
        participantNames[u.uid] = u.displayName;
      }
    }

    final chatRoomId = await ref
        .read(chatActionsProvider.notifier)
        .createGroupChat(
          creatorId: creatorId,
          groupName: groupName,
          participantIds: participantIds,
          participantNames: participantNames,
        );

    if (!mounted) return;

    if (chatRoomId != null) {
      context.pushReplacement('/chat/$chatRoomId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create group. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          allUsersAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (users) => IconButton(
              tooltip: 'Create',
              icon: const Icon(Icons.check),
              onPressed: () => _createGroup(users),
            ),
          ),
        ],
      ),
      body: allUsersAsync.when(
        loading: () => const LoadingWidget(message: 'Loading users...'),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load users',
          subtitle: error.toString(),
        ),
        data: (users) {
          final filtered = _searchQuery.isEmpty
              ? users
              : users
                    .where(
                      (u) =>
                          u.displayName.toLowerCase().contains(_searchQuery) ||
                          u.email.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _groupNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Group name',
                    hintText: 'Enter a group name',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No users found',
                        subtitle: 'Try a different search term',
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final isSelected = _selectedUserIds.contains(
                            user.uid,
                          );

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
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUserIds.add(user.uid);
                                  } else {
                                    _selectedUserIds.remove(user.uid);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedUserIds.remove(user.uid);
                                } else {
                                  _selectedUserIds.add(user.uid);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
