// SmartChat - App Routes
//
// Defines all application routes using GoRouter.
// Handles navigation between screens with path parameters.

import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/new_chat_screen.dart';
import '../screens/chat/new_group_chat_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/change_email_screen.dart';

/// The application's route configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash screen — initial route
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // Authentication routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Main home screen (tabs: chats, AI, profile)
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Individual chat screen
    GoRoute(
      path: '/chat/:chatRoomId',
      builder: (context, state) {
        final chatRoomId = state.pathParameters['chatRoomId']!;
        return ChatScreen(chatRoomId: chatRoomId);
      },
    ),

    // New chat (search users) screen
    GoRoute(
      path: '/new-chat',
      builder: (context, state) => const NewChatScreen(),
    ),

    // New group chat screen
    GoRoute(
      path: '/new-group',
      builder: (context, state) => const NewGroupChatScreen(),
    ),

    // Edit profile screen
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // Change password screen
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // Change email screen
    GoRoute(
      path: '/change-email',
      builder: (context, state) => const ChangeEmailScreen(),
    ),
  ],
);
