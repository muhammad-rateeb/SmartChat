// SmartChat - AI Provider
//
// Riverpod providers for AI assistant state management.
// Manages AI conversation flow and message persistence.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../models/ai_message_model.dart';
import 'auth_provider.dart';

/// Singleton provider for the [AiService].
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Stream provider for AI chat messages of the current user.
final aiMessagesProvider = StreamProvider<List<AiMessageModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  final aiService = ref.watch(aiServiceProvider);
  return aiService.getAiMessagesStream(userId);
});

/// State notifier for AI chat actions.
final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final aiService = ref.watch(aiServiceProvider);
  return AiChatNotifier(aiService);
});

// ─── AI Chat State ──────────────────────────────────────

/// Represents the current state of an AI conversation.
class AiChatState {
  /// Whether the AI is currently generating a response.
  final bool isLoading;

  /// Error message if the last AI call failed.
  final String? errorMessage;

  const AiChatState({this.isLoading = false, this.errorMessage});

  AiChatState copyWith({bool? isLoading, String? errorMessage}) {
    return AiChatState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── AI Chat Notifier ───────────────────────────────────

/// Manages AI chat actions: sending prompts and receiving responses.
class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiService _aiService;

  AiChatNotifier(this._aiService) : super(const AiChatState());

  /// Sends a user prompt to the AI and saves both the prompt
  /// and the response to Firestore.
  Future<void> sendPrompt({
    required String userId,
    required String prompt,
  }) async {
    if (prompt.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Save the user's message
      await _aiService.saveUserMessage(userId: userId, content: prompt.trim());

      // Get AI response from Gemini API
      final response = await _aiService.getAiResponse(prompt.trim());

      // Save the AI response
      await _aiService.saveAiResponse(userId: userId, content: response);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Save an error message so the user can see what went wrong
      try {
        await _aiService.saveAiResponse(
          userId: userId,
          content: _formatErrorMessage(e.toString()),
          isError: true,
        );
      } catch (_) {
        // Ignore secondary failure — focus on resetting isLoading
      }
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Formats error messages to be user-friendly.
  String _formatErrorMessage(String error) {
    // Remove "Exception: " prefix if present
    String message = error.replaceFirst(RegExp(r'^Exception:\s*'), '');

    // Return user-friendly messages
    if (message.contains('No internet') ||
        message.contains('SocketException')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }
    if (message.contains('timed out') || message.contains('Timeout')) {
      return 'The request took too long. Please try again.';
    }
    if (message.contains('API key') || message.contains('authentication')) {
      return 'There was an authentication issue. Please contact support.';
    }
    if (message.contains('Too many requests') ||
        message.contains('429') ||
        message.contains('Currently receiving too many requests.')) {
      return 'I am receiving too many requests right now. Please wait for a few moments and try again.';
    }
    if (message.contains('unavailable') || message.contains('500')) {
      return 'The AI service is temporarily unavailable. Please try again later.';
    }

    // Return the cleaned message for other errors
    return message.isNotEmpty
        ? message
        : 'Sorry, something went wrong. Please try again.';
  }

  /// Clears all AI chat history for the user.
  Future<void> clearChat(String userId) async {
    try {
      await _aiService.clearAiChat(userId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to clear chat: $e');
    }
  }
}
