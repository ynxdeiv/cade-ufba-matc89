import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class CriarConversa implements UseCase<ChatConversation, NoParams> {
  CriarConversa(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, ChatConversation>> call(NoParams params) {
    return _repository.criarConversa();
  }
}
