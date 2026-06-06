import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

enum ChatRole { user, assistant }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required int id,
    required String conversationId,
    required ChatRole role,
    required String conteudo,
    required DateTime createdAt,
  }) = _ChatMessage;
}
