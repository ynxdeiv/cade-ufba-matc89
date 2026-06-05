import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/evento.dart';
import '../repositories/event_repository.dart';

class ObterEvento implements UseCase<Evento, String> {
  ObterEvento(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, Evento>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('id', 'id do evento é obrigatório')),
      );
    }
    return _repository.obter(id.trim());
  }
}
