import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/criar_conversa.dart';
import '../../domain/usecases/listar_conversas.dart';
import '../../domain/usecases/listar_mensagens.dart';
import '../../domain/usecases/streamar_mensagem.dart';

// ------------------------------------------------------------------
// Infra (datasource + repository + usecases)
// ------------------------------------------------------------------

final _remoteProvider = Provider<ChatRemoteDatasource>(
  (_) => ChatRemoteDatasource(
    sb.Supabase.instance.client,
    Dio(),
  ),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(ref.watch(_remoteProvider)),
);

final _listarConversasProvider = Provider<ListarConversas>(
  (ref) => ListarConversas(ref.watch(chatRepositoryProvider)),
);

final _criarConversaProvider = Provider<CriarConversa>(
  (ref) => CriarConversa(ref.watch(chatRepositoryProvider)),
);

final _listarMensagensProvider = Provider<ListarMensagens>(
  (ref) => ListarMensagens(ref.watch(chatRepositoryProvider)),
);

final _streamarMensagemProvider = Provider<StreamarMensagem>(
  (ref) => StreamarMensagem(ref.watch(chatRepositoryProvider)),
);

// ------------------------------------------------------------------
// Conversas (lista no drawer)
// ------------------------------------------------------------------

class ConversasState {
  const ConversasState({
    required this.conversas,
    required this.carregando,
    this.erro,
  });

  factory ConversasState.inicial() => const ConversasState(
        conversas: [],
        carregando: false,
      );

  final List<ChatConversation> conversas;
  final bool carregando;
  final Failure? erro;

  ConversasState copyWith({
    List<ChatConversation>? conversas,
    bool? carregando,
    Failure? erro,
    bool limparErro = false,
  }) {
    return ConversasState(
      conversas: conversas ?? this.conversas,
      carregando: carregando ?? this.carregando,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }
}

class ConversasController extends StateNotifier<ConversasState> {
  ConversasController(this._listar, this._criar)
      : super(ConversasState.inicial());

  final ListarConversas _listar;
  final CriarConversa _criar;

  Future<void> carregar() async {
    state = state.copyWith(carregando: true, limparErro: true);
    final r = await _listar(const NoParams());
    state = r.fold(
      (f) => state.copyWith(carregando: false, erro: f),
      (lista) => state.copyWith(carregando: false, conversas: lista),
    );
  }

  Future<String?> criar() async {
    final r = await _criar(const NoParams());
    return r.fold(
      (f) {
        state = state.copyWith(erro: f);
        return null;
      },
      (conversa) {
        state = state.copyWith(
          conversas: [conversa, ...state.conversas],
        );
        return conversa.id;
      },
    );
  }

  void marcarAtividade(String conversationId) {
    final agora = DateTime.now();
    final atualizada = [
      for (final c in state.conversas)
        if (c.id == conversationId) c.copyWith(updatedAt: agora) else c,
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(conversas: atualizada);
  }
}

final conversasControllerProvider =
    StateNotifierProvider<ConversasController, ConversasState>(
  (ref) => ConversasController(
    ref.watch(_listarConversasProvider),
    ref.watch(_criarConversaProvider),
  ),
);

// ------------------------------------------------------------------
// Chat de uma conversa específica (family por conversationId)
// ------------------------------------------------------------------

class ChatState {
  const ChatState({
    required this.mensagens,
    required this.carregando,
    required this.enviando,
    this.erro,
    this.textoStreaming,
  });

  factory ChatState.inicial() => const ChatState(
        mensagens: [],
        carregando: false,
        enviando: false,
      );

  final List<ChatMessage> mensagens;
  final bool carregando;
  final bool enviando;
  final Failure? erro;

  /// Texto do assistente sendo recebido em streaming. `null` = não está streamando.
  final String? textoStreaming;

  ChatState copyWith({
    List<ChatMessage>? mensagens,
    bool? carregando,
    bool? enviando,
    Failure? erro,
    bool limparErro = false,
    String? textoStreaming,
    bool limparStreaming = false,
  }) {
    return ChatState(
      mensagens: mensagens ?? this.mensagens,
      carregando: carregando ?? this.carregando,
      enviando: enviando ?? this.enviando,
      erro: limparErro ? null : (erro ?? this.erro),
      textoStreaming: limparStreaming ? null : (textoStreaming ?? this.textoStreaming),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._listar, this._streamar, this._conversationId)
      : super(ChatState.inicial());

  final ListarMensagens _listar;
  final StreamarMensagem _streamar;
  final String _conversationId;

  Future<void> carregar() async {
    state = state.copyWith(carregando: true, limparErro: true);
    final r = await _listar(_conversationId);
    state = r.fold(
      (f) => state.copyWith(carregando: false, erro: f),
      (lista) => state.copyWith(carregando: false, mensagens: lista),
    );
  }

  Future<bool> enviar(String conteudo) async {
    final texto = conteudo.trim();
    if (texto.isEmpty) return false;

    // Adiciona mensagem do usuário otimisticamente
    final userMsg = ChatMessage(
      id: -1,
      conversationId: _conversationId,
      role: ChatRole.user,
      conteudo: texto,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      enviando: true,
      limparErro: true,
      mensagens: [...state.mensagens, userMsg],
      textoStreaming: '',
    );

    String textoFinal = '';
    bool sucesso = true;

    await for (final either in _streamar(ParametrosStreamarMensagem(
      conversationId: _conversationId,
      conteudo: texto,
    ))) {
      either.fold(
        (f) {
          state = state.copyWith(
            enviando: false,
            erro: f,
            limparStreaming: true,
            // Remove mensagem otimista em caso de erro
            mensagens: state.mensagens
                .where((m) => m.id != -1)
                .toList(),
          );
          sucesso = false;
        },
        (chunk) {
          textoFinal += chunk;
          state = state.copyWith(textoStreaming: textoFinal);
        },
      );
      if (!sucesso) return false;
    }

    // Streaming concluído — recarrega mensagens do banco (IDs reais)
    final r = await _listar(_conversationId);
    state = r.fold(
      (f) => state.copyWith(
        enviando: false,
        limparStreaming: true,
        erro: f,
      ),
      (lista) => state.copyWith(
        enviando: false,
        limparStreaming: true,
        mensagens: lista,
      ),
    );

    return sucesso;
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController,
    ChatState, String>(
  (ref, conversationId) => ChatController(
    ref.watch(_listarMensagensProvider),
    ref.watch(_streamarMensagemProvider),
    conversationId,
  ),
);
