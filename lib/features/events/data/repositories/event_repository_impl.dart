import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/filtro_evento.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_datasource.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._remote, this._local);

  final EventRemoteDatasource _remote;
  final EventLocalDatasource _local;

  @override
  Future<Either<Failure, List<Evento>>> listar({
    required FiltroEvento filtro,
    required int limit,
    required int offset,
  }) async {
    try {
      final modelos = await _remote.listar(
        filtro: filtro,
        limit: limit,
        offset: offset,
      );
      // Hidrata o cache só quando é a "primeira página neutra" — o
      // único caso útil para abrir o app offline.
      if (filtro.neutro && offset == 0) {
        await _local.salvarPrimeiraPagina(modelos);
      }
      return Right(modelos.map((m) => m.toEntity()).toList(growable: false));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<List<Evento>> primeiraPaginaCacheada() async {
    final modelos = await _local.recuperarPrimeiraPagina();
    return modelos.map((m) => m.toEntity()).toList(growable: false);
  }
}
