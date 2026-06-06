import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.conteudo,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: (json['id'] as num).toInt(),
        conversationId: json['conversation_id'] as String,
        role: _parseRole(json['role'] as String),
        conteudo: json['conteudo'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  static ChatRole _parseRole(String raw) => switch (raw) {
        'user' => ChatRole.user,
        'assistant' => ChatRole.assistant,
        _ => ChatRole.assistant,
      };

  final int id;
  final String conversationId;
  final ChatRole role;
  final String conteudo;
  final DateTime createdAt;

  ChatMessage toEntity() => ChatMessage(
        id: id,
        conversationId: conversationId,
        role: role,
        conteudo: conteudo,
        createdAt: createdAt,
      );
}
