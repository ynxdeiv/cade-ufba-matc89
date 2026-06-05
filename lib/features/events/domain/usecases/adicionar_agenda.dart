import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/event_repository.dart';

class AdicionarAgenda implements UseCase<void, String> {
  AdicionarAgenda(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, void>> call(String eventId) {
    if (eventId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('eventId', 'id do evento é obrigatório')),
      );
    }
    return _repository.adicionarAgenda(eventId.trim());
  }
}

class RemoverAgenda implements UseCase<void, String> {
  RemoverAgenda(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, void>> call(String eventId) {
    if (eventId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('eventId', 'id do evento é obrigatório')),
      );
    }
    return _repository.removerAgenda(eventId.trim());
  }
}
