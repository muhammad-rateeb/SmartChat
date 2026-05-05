// SmartChat - Profile Screen
//
// Displays the current user's profile with options to edit,
// toggle dark mode, and sign out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: userAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return ListView(
            children: [
              const SizedBox(height: 24),

              // Avatar and info
              Center(
                child: Column(
                  children: [
                    UserAvatar(
                      name: user.displayName,
                      photoURL: user.photoURL,
                      radius: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),

              // Edit Profile
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/edit-profile'),
              ),

              // Change Password
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/change-password'),
              ),

              // Change Email
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Change Email'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/change-email'),
              ),

              // Dark Mode Toggle
              SwitchListTile(
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text('Dark Mode'),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),

              const Divider(),

              // About
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About SmartChat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'SmartChat',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2026 SmartChat. All rights reserved.',
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'A real-time chat application with AI assistant, '
                        'built with Flutter and Firebase.',
                      ),
                    ],
                  );
                },
              ),

              const Divider(),

              // Logout
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _showLogoutDialog(context, ref),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog before logout.
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              // Clear any cached chat/user streams tied to the previous account.
              ref.invalidate(chatRoomsProvider);
              ref.invalidate(messagesProvider);
              ref.invalidate(currentUserProfileProvider);
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
