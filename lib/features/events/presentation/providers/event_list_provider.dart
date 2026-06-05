import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/failures.dart';
import '../../data/datasources/event_local_datasource.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/filtro_evento.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/listar_eventos.dart';

const int kEventoPaginaTamanho = 20;
const Duration kBuscaDebounce = Duration(milliseconds: 300);

class EventListState {
  const EventListState({
    required this.eventos,
    required this.filtro,
    required this.carregandoInicial,
    required this.carregandoMais,
    required this.fim,
    required this.servindoDoCache,
    this.erro,
  });

  factory EventListState.inicial() => const EventListState(
        eventos: [],
        filtro: FiltroEvento(),
        carregandoInicial: false,
        carregandoMais: false,
        fim: false,
        servindoDoCache: false,
      );

  final List<Evento> eventos;
  final FiltroEvento filtro;
  final bool carregandoInicial;
  final bool carregandoMais;
  final bool fim;
  final bool servindoDoCache;
  final Failure? erro;

  EventListState copyWith({
    List<Evento>? eventos,
    FiltroEvento? filtro,
    bool? carregandoInicial,
    bool? carregandoMais,
    bool? fim,
    bool? servindoDoCache,
    Failure? erro,
    bool limparErro = false,
  }) {
    return EventListState(
      eventos: eventos ?? this.eventos,
      filtro: filtro ?? this.filtro,
      carregandoInicial: carregandoInicial ?? this.carregandoInicial,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      fim: fim ?? this.fim,
      servindoDoCache: servindoDoCache ?? this.servindoDoCache,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }
}

class EventListController extends StateNotifier<EventListState> {
  EventListController(this._listar, this._repository)
      : super(EventListState.inicial());

  final ListarEventos _listar;
  final EventRepository _repository;
  Timer? _debounce;

  /// Carrega a primeira página com o filtro atual. Chamado no
  /// `initState` da tela e quando o usuário muda busca/filtros.
  Future<void> carregarPrimeiraPagina() async {
    state = state.copyWith(
      eventos: const [],
      carregandoInicial: true,
      fim: false,
      limparErro: true,
    );

    final r = await _listar(
      ParametrosListarEventos(
        filtro: state.filtro,
        limit: kEventoPaginaTamanho,
        offset: 0,
      ),
    );

    await r.fold(
      (f) async {
        // Fallback offline — só faz sentido sem filtros aplicados,
        // pois é a única coisa cacheada.
        final cache = state.filtro.neutro
            ? await _repository.primeiraPaginaCacheada()
            : const <Evento>[];
        state = state.copyWith(
          carregandoInicial: false,
          erro: f,
          eventos: cache,
          servindoDoCache: cache.isNotEmpty,
          fim: cache.length < kEventoPaginaTamanho,
        );
      },
      (lista) async {
        state = state.copyWith(
          carregandoInicial: false,
          eventos: lista,
          servindoDoCache: false,
          fim: lista.length < kEventoPaginaTamanho,
          limparErro: true,
        );
      },
    );
  }

  Future<void> carregarProximaPagina() async {
    if (state.carregandoInicial ||
        state.carregandoMais ||
        state.fim ||
        state.servindoDoCache) {
      return;
    }
    state = state.copyWith(carregandoMais: true);

    final r = await _listar(
      ParametrosListarEventos(
        filtro: state.filtro,
        limit: kEventoPaginaTamanho,
        offset: state.eventos.length,
      ),
    );

    state = r.fold(
      (f) => state.copyWith(carregandoMais: false, erro: f),
      (lista) => state.copyWith(
        carregandoMais: false,
        eventos: [...state.eventos, ...lista],
        fim: lista.length < kEventoPaginaTamanho,
        limparErro: true,
      ),
    );
  }

  /// Debounce 300ms — atualiza filtro.busca e recarrega.
  void atualizarBusca(String texto) {
    _debounce?.cancel();
    _debounce = Timer(kBuscaDebounce, () {
      final novoFiltro = state.filtro.copyWith(
        busca: texto.trim().isEmpty ? null : texto.trim(),
      );
      state = state.copyWith(filtro: novoFiltro);
      carregarPrimeiraPagina();
    });
  }

  void aplicarFiltro(FiltroEvento f) {
    state = state.copyWith(filtro: f);
    carregarPrimeiraPagina();
  }

  /// Alterna a categoria selecionada via chips (clicar de novo
  /// desmarca).
  void alternarCategoria(String? categoria) {
    final atual = state.filtro.categoria;
    final novoFiltro = state.filtro.copyWith(
      categoria: atual == categoria ? null : categoria,
    );
    aplicarFiltro(novoFiltro);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ------------------------------------------------------------------
// Providers
// ------------------------------------------------------------------

final _remoteProvider = Provider<EventRemoteDatasource>(
  (_) => EventRemoteDatasource(sb.Supabase.instance.client),
);

final _localProvider = Provider<EventLocalDatasource>(
  (_) => EventLocalDatasource(),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepositoryImpl(
    ref.watch(_remoteProvider),
    ref.watch(_localProvider),
  ),
);

final _listarEventosProvider = Provider<ListarEventos>(
  (ref) => ListarEventos(ref.watch(eventRepositoryProvider)),
);

final eventListControllerProvider =
    StateNotifierProvider<EventListController, EventListState>(
  (ref) => EventListController(
    ref.watch(_listarEventosProvider),
    ref.watch(eventRepositoryProvider),
  ),
);
