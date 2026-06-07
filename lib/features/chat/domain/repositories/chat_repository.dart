import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversation>>> listarConversas();

  Future<Either<Failure, ChatConversation>> criarConversa();

  Future<Either<Failure, List<ChatMessage>>> listarMensagens(
    String conversationId,
  );

  /// Persiste a mensagem do usuário e a resposta stub do assistente em
  /// `chat_messages`. Retorna ambas, já com `id` e `createdAt` do banco.
  Future<Either<Failure, List<ChatMessage>>> enviarMensagem({
    required String conversationId,
    required String conteudo,
  });
}
