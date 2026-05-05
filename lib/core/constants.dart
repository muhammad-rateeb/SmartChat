import 'package:flutter_dotenv/flutter_dotenv.dart';

// SmartChat - Core Constants
//
// Application-wide constant values used across the app.
// Centralizes configuration for easy maintenance.

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ─── App Info ─────────────────────────────────────────
  static const String appName = 'SmartChat';
  static const String appVersion = '1.0.0';

  // ─── Firebase Collections ─────────────────────────────
  static const String usersCollection = 'users';
  static const String chatRoomsCollection = 'chatRooms';
  static const String messagesSubCollection = 'messages';
  static const String aiChatsCollection = 'aiChats';

  // ─── AI Configuration ─────────────────────────────────
  /// Gemini API key loaded securely via dotenv
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  // ─── Chat Room Types ──────────────────────────────────
  static const String chatTypeOneToOne = 'oneToOne';
  static const String chatTypeGroup = 'group';
  static const String chatTypeAI = 'ai';

  // ─── Message Types ────────────────────────────────────
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeAudio = 'audio';
  static const String messageTypeAiResponse = 'ai_response';

  // ─── Storage Paths ────────────────────────────────────
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';

  // ─── UI Constants ─────────────────────────────────────
  static const double borderRadius = 12.0;
  static const double avatarRadius = 24.0;
  static const double inputHeight = 48.0;
  static const int messagePageSize = 50;

  // ─── Shared Preferences Keys ──────────────────────────
  static const String themeKey = 'theme_mode';
  static const String fcmTokenKey = 'fcm_token';
}
