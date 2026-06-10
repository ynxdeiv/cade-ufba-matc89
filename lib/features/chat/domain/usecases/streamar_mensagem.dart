import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class ParametrosStreamarMensagem {
  const ParametrosStreamarMensagem({
    required this.conversationId,
    required this.conteudo,
  });

  final String conversationId;
  final String conteudo;
}

class StreamarMensagem {
  StreamarMensagem(this._repository);

  final ChatRepository _repository;

  Stream<Either<Failure, String>> call(ParametrosStreamarMensagem params) {
    return _repository.streamarMensagem(
      conversationId: params.conversationId,
      conteudo: params.conteudo,
    );
  }
}
