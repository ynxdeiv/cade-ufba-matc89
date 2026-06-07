import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';

@freezed
class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    required String titulo,
    required DateTime updatedAt,
    required DateTime createdAt,
  }) = _ChatConversation;
}
