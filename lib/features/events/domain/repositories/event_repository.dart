import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../entities/filtro_evento.dart';

abstract class EventRepository {
  /// Lista eventos paginados. Quando o filtro é neutro e [offset] é 0,
  /// o impl pode optar por hidratar/atualizar o cache offline.
  Future<Either<Failure, List<Evento>>> listar({
    required FiltroEvento filtro,
    required int limit,
    required int offset,
  });

  /// Lê apenas o cache local (sem rede). Usado pelo controller para
  /// exibir conteúdo imediato quando a rede falha.
  Future<List<Evento>> primeiraPaginaCacheada();
}
