// SmartChat - AI Service
//
// Integrates with Google Gemini REST API to provide
// AI assistant functionality within the app.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_message_model.dart';
import '../core/constants.dart';

class AiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ─── Gemini API Integration ───────────────────────────

  /// Sends a user [prompt] to the Gemini API and returns the
  /// AI-generated response text.
  ///
  /// Throws an [Exception] if the API call fails.
  Future<String> getAiResponse(String prompt) async {
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final url = Uri.parse(
          '${AppConstants.geminiBaseUrl}?key=${AppConstants.geminiApiKey}',
        );

        // Add timeout to prevent hanging requests
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'topK': 40,
                  'topP': 0.95,
                  'maxOutputTokens': 1024,
                },
              }),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw TimeoutException(
                'Request timed out. Please check your internet connection.',
              ),
            );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text'] as String? ?? 'No response generated.';
            }
          }
          return 'No response generated.';
        } else if (response.statusCode == 400) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final error = data['error']?['message'] ?? 'Invalid request';
          throw Exception('Bad request: $error');
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception(
            'API authentication failed. Please check your API key. (Response: ${response.body})',
          );
        } else if (response.statusCode == 429) {
          debugPrint('RATE LIMIT TRIGGERED: ${response.body}');
          if (retryCount < maxRetries) {
            retryCount++;
            // Exponential backoff with longer wait time
            await Future.delayed(Duration(seconds: 4 * retryCount));
            continue;
          } else {
            throw Exception(
              'Currently receiving too many requests. Please wait for a while before trying again.',
            );
          }
        } else if (response.statusCode >= 500) {
          throw Exception(
            'AI service is temporarily unavailable. Please try again later.',
          );
        } else {
          throw Exception(
            'Unexpected error (${response.statusCode}). Please try again.',
          );
        }
      } on SocketException {
        throw Exception(
          'No internet connection. Please check your network settings.',
        );
      } on TimeoutException catch (e) {
        throw Exception(e.message ?? 'Request timed out. Please try again.');
      } on FormatException {
        throw Exception('Failed to parse AI response. Please try again.');
      } catch (e) {
        if (e is Exception &&
            e.toString().contains('Too many requests') &&
            retryCount >= maxRetries) {
          rethrow;
        } else if (e is Exception &&
            !e.toString().contains('Too many requests')) {
          rethrow;
        }
        throw Exception('Failed to get AI response: $e');
      }
    }

    throw Exception('Failed to get AI response after retries.');
  }

  // ─── AI Chat Persistence ──────────────────────────────

  /// Returns a real-time stream of AI chat messages for [userId].
  /// Ordered by timestamp (newest first).
  Stream<List<AiMessageModel>> getAiMessagesStream(String userId) {
    return _firestore
        .collection(AppConstants.aiChatsCollection)
        .doc(userId)
        .collection(AppConstants.messagesSubCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AiMessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Saves a user message to the AI chat history in Firestore.
  Future<AiMessageModel> saveUserMessage({
    required String userId,
    required String content,
  }) async {
    final messageId = _uuid.v4();
    final message = AiMessageModel(
      id: messageId,
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.aiChatsCollection)
        .doc(userId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .set(message.toMap());

    return message;
  }

  /// Saves an AI assistant response to the chat history in Firestore.
  Future<AiMessageModel> saveAiResponse({
    required String userId,
    required String content,
    bool isError = false,
  }) async {
    final messageId = _uuid.v4();
    final message = AiMessageModel(
      id: messageId,
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      isError: isError,
    );

    await _firestore
        .collection(AppConstants.aiChatsCollection)
        .doc(userId)
        .collection(AppConstants.messagesSubCollection)
        .doc(messageId)
        .set(message.toMap());

    return message;
  }

  /// Clears all AI chat messages for [userId].
  /// Handles Firestore's 500-operation batch limit.
  Future<void> clearAiChat(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.aiChatsCollection)
        .doc(userId)
        .collection(AppConstants.messagesSubCollection)
        .get();

    // Chunk deletes into batches of 400 to stay under Firestore's 500 limit
    const batchSize = 400;
    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize < docs.length) ? i + batchSize : docs.length;
      for (var j = i; j < end; j++) {
        batch.delete(docs[j].reference);
      }
      await batch.commit();
    }
  }
}
