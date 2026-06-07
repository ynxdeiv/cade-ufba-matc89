import '../../domain/entities/chat_conversation.dart';

class ChatConversationModel {
  const ChatConversationModel({
    required this.id,
    required this.titulo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) =>
      ChatConversationModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  final String id;
  final String titulo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation toEntity() => ChatConversation(
        id: id,
        titulo: titulo,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
