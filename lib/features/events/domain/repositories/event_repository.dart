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

  /// Busca um único evento por id (necessário pelo deep link
  /// `/eventos/:id`, que pode abrir a tela sem ter carregado a lista).
  Future<Either<Failure, Evento>> obter(String id);

  /// BE-004: marca o evento na agenda do usuário autenticado.
  Future<Either<Failure, void>> adicionarAgenda(String eventId);

  /// BE-004: remove o evento da agenda do usuário autenticado.
  Future<Either<Failure, void>> removerAgenda(String eventId);

  /// Retorna true se o usuário autenticado já marcou o evento.
  Future<Either<Failure, bool>> estaNaAgenda(String eventId);
}
