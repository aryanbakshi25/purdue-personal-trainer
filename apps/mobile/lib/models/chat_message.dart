/// Mirrors the ChatMessage/ChatRequest/ChatResponse schemas from @ppt/shared.
class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String?,
    );
  }

  final String role;
  final String content;
  final String? timestamp;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
