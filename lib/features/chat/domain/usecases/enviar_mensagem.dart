import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class ParametrosEnviarMensagem extends Equatable {
  const ParametrosEnviarMensagem({
    required this.conversationId,
    required this.conteudo,
  });

  final String conversationId;
  final String conteudo;

  @override
  List<Object?> get props => [conversationId, conteudo];
}

class EnviarMensagem
    implements UseCase<List<ChatMessage>, ParametrosEnviarMensagem> {
  EnviarMensagem(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(
    ParametrosEnviarMensagem params,
  ) async {
    final conteudo = params.conteudo.trim();
    if (conteudo.isEmpty) {
      return const Left(
        ValidationFailure('conteudo', 'mensagem não pode estar vazia'),
      );
    }
    return _repository.enviarMensagem(
      conversationId: params.conversationId,
      conteudo: conteudo,
    );
  }
}
