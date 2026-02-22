import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import 'api_provider.dart';

/// Chat state: list of messages in the current conversation.
final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._ref) : super([]);

  final Ref _ref;

  Future<void> sendMessage(String text) async {
    // Add user message
    final userMsg = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
    state = [...state, userMsg];

    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.post<Map<String, dynamic>>(
        '/api/chat',
        data: {
          'message': text,
          'conversationHistory':
              state.map((m) => m.toJson()).toList(),
        },
      );

      final data = response.data!;
      final assistantMsg = ChatMessage(
        role: 'assistant',
        content: data['reply'] as String,
        timestamp: DateTime.now().toUtc().toIso8601String(),
      );
      state = [...state, assistantMsg];
    } catch (e) {
      final errorMsg = ChatMessage(
        role: 'assistant',
        content:
            'Sorry, I encountered an error. Please try again.',
        timestamp: DateTime.now().toUtc().toIso8601String(),
      );
      state = [...state, errorMsg];
    }
  }

  void clearHistory() {
    state = [];
  }
}
