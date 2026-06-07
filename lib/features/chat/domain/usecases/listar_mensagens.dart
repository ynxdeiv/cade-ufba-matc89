import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class ListarMensagens implements UseCase<List<ChatMessage>, String> {
  ListarMensagens(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(String conversationId) {
    return _repository.listarMensagens(conversationId);
  }
}
