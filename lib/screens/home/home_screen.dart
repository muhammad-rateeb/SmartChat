// SmartChat - Home Screen
//
// Main tabbed screen with three tabs: Chats, AI Assistant, Profile.
// Manages bottom navigation and contains the app's primary navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat/chat_list_screen.dart';
import '../ai/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/chat_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  /// The three main tab screens.
  final List<Widget> _screens = const [
    ChatListScreen(),
    AiChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch the chatRoomsProvider to get the total number of chats
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final int chatCount = chatRoomsAsync.when(
      data: (rooms) => rooms.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: chatCount > 0,
              label: Text(chatCount.toString()),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: chatCount > 0,
              label: Text(chatCount.toString()),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI Assistant',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
