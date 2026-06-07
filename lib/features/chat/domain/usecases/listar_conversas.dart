import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class ListarConversas implements UseCase<List<ChatConversation>, NoParams> {
  ListarConversas(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatConversation>>> call(NoParams params) {
    return _repository.listarConversas();
  }
}
