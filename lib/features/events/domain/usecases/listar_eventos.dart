import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/evento.dart';
import '../entities/filtro_evento.dart';
import '../repositories/event_repository.dart';

class ParametrosListarEventos extends Equatable {
  const ParametrosListarEventos({
    required this.filtro,
    this.limit = 20,
    this.offset = 0,
  });

  final FiltroEvento filtro;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [filtro, limit, offset];
}

class ListarEventos
    implements UseCase<List<Evento>, ParametrosListarEventos> {
  ListarEventos(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, List<Evento>>> call(
    ParametrosListarEventos params,
  ) async {
    if (params.limit <= 0 || params.limit > 100) {
      return const Left(
        ValidationFailure('limit', 'limit precisa estar entre 1 e 100'),
      );
    }
    if (params.offset < 0) {
      return const Left(
        ValidationFailure('offset', 'offset não pode ser negativo'),
      );
    }
    return _repository.listar(
      filtro: params.filtro,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
