// SmartChat - Notification Service
//
// Handles Firebase Cloud Messaging (FCM) setup and push notifications.
// Manages token registration and foreground notification display.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserService _userService = UserService();
  bool _initialized = false;

  // ─── Initialization ───────────────────────────────────

  /// Initializes FCM: requests permission, gets token, and
  /// sets up foreground/background message handlers.
  Future<void> initialize(String userId) async {
    // Prevent duplicate initialization
    if (_initialized) return;
    _initialized = true;

    // Request notification permission (iOS & web)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get and store the FCM token
      await _getAndStoreToken(userId);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          await _userService.updateFcmToken(userId: userId, token: newToken);
        } catch (e) {
          debugPrint('Failed to update FCM token: $e');
        }
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background/terminated message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    }
  }

  // ─── Token Management ─────────────────────────────────

  /// Retrieves the FCM token and stores it in Firestore.
  Future<void> _getAndStoreToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _userService.updateFcmToken(userId: userId, token: token);
        debugPrint('FCM Token: $token');
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  // ─── Message Handlers ─────────────────────────────────

  /// Handles messages received while the app is in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    // In production, show a local notification or in-app banner here.
    // You could use flutter_local_notifications package for this.
  }

  /// Handles notification taps when app is in background/terminated.
  void _handleMessageTap(RemoteMessage message) {
    debugPrint('Message tap: ${message.data}');
    // In production, navigate to the relevant chat screen
    // based on message.data['chatRoomId'].
  }

  // ─── Topic Subscription ───────────────────────────────

  /// Subscribes the user to a topic (e.g., a chat room).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribes the user from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
