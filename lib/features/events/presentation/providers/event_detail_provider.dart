import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/evento.dart';
import '../../domain/usecases/adicionar_agenda.dart';
import '../../domain/usecases/obter_evento.dart';
import 'event_list_provider.dart';

/// Carrega o evento por id — usado pela [DetalheEventoScreen] e
/// funciona tanto quando o usuário chega via tap no card quanto via
/// deep link `/eventos/:id` direto.
final eventoPorIdProvider = FutureProvider.family<Evento, String>(
  (ref, id) async {
    final usecase = ObterEvento(ref.watch(eventRepositoryProvider));
    final r = await usecase(id);
    return r.fold((f) => throw _falhaParaErro(f), (e) => e);
  },
);

/// Estado do botão "Adicionar/Remover da agenda" — uma family por
/// event_id para preservar o estado em múltiplas instâncias da tela.
class AgendaState {
  const AgendaState({
    required this.naAgenda,
    required this.carregando,
    this.erro,
  });

  factory AgendaState.inicial() =>
      const AgendaState(naAgenda: false, carregando: true);

  final bool naAgenda;
  final bool carregando;
  final String? erro;

  AgendaState copyWith({bool? naAgenda, bool? carregando, String? erro}) =>
      AgendaState(
        naAgenda: naAgenda ?? this.naAgenda,
        carregando: carregando ?? this.carregando,
        erro: erro,
      );
}

class AgendaController extends StateNotifier<AgendaState> {
  AgendaController(this._ref, this._eventId) : super(AgendaState.inicial()) {
    _verificar();
  }

  final Ref _ref;
  final String _eventId;

  Future<void> _verificar() async {
    final repo = _ref.read(eventRepositoryProvider);
    final r = await repo.estaNaAgenda(_eventId);
    state = r.fold(
      (f) => AgendaState(
        naAgenda: false,
        carregando: false,
        erro: _falhaParaMensagem(f),
      ),
      (esta) => AgendaState(naAgenda: esta, carregando: false),
    );
  }

  Future<bool> alternar() async {
    state = state.copyWith(carregando: true, erro: null);
    final repo = _ref.read(eventRepositoryProvider);
    final Either<Failure, void> r = state.naAgenda
        ? await RemoverAgenda(repo)(_eventId)
        : await AdicionarAgenda(repo)(_eventId);

    final sucesso = r.isRight();
    state = r.fold(
      (f) => state.copyWith(carregando: false, erro: _falhaParaMensagem(f)),
      (_) => AgendaState(naAgenda: !state.naAgenda, carregando: false),
    );
    return sucesso;
  }
}

final agendaProvider =
    StateNotifierProvider.family<AgendaController, AgendaState, String>(
  (ref, eventId) => AgendaController(ref, eventId),
);

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

Object _falhaParaErro(Failure f) => _FalhaErro(_falhaParaMensagem(f));

String _falhaParaMensagem(Failure f) {
  if (f is NetworkFailure) return 'Sem conexão. Tente de novo.';
  if (f is ServerFailure) return f.mensagem ?? 'Falha no servidor.';
  if (f is AuthFailure) return f.mensagem ?? 'Faça login novamente.';
  return f.mensagem ?? 'Algo deu errado.';
}

class _FalhaErro implements Exception {
  _FalhaErro(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}
