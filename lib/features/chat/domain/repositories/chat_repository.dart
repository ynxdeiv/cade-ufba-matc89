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

  /// Envia a mensagem via edge function e retorna um stream de chunks de texto.
  /// O último evento emite `done: true` indicando que o banco já foi atualizado.
  Stream<Either<Failure, String>> streamarMensagem({
    required String conversationId,
    required String conteudo,
  });
}
