import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/chat_providers.dart';
import '../widgets/barra_envio.dart';
import '../widgets/bolha_mensagem.dart';
import '../widgets/lista_conversas_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversaId});

  final String? conversaId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scroll = ScrollController();
  String? _ultimaConversaCarregada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversasControllerProvider.notifier).carregar();
      _carregarConversaSeNecessario();
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _carregarConversaSeNecessario();
  }

  void _carregarConversaSeNecessario() {
    final id = widget.conversaId;
    if (id != null && id != _ultimaConversaCarregada) {
      _ultimaConversaCarregada = id;
      ref.read(chatControllerProvider(id).notifier).carregar();
    }
  }

  void _scrollParaFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _criarNovaConversa() async {
    final id = await ref.read(conversasControllerProvider.notifier).criar();
    if (id != null && mounted) {
      context.go('/home/chat?conversa=$id');
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.conversaId;

    return Scaffold(
      backgroundColor: AppCores.neutro100,
      drawer: ListaConversasDrawer(conversaAtivaId: id),
      appBar: AppBar(
        backgroundColor: AppCores.azul900,
        foregroundColor: Colors.white,
        title: const Text(
          'Cadu',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Nova conversa',
            icon: const Icon(Icons.add),
            onPressed: _criarNovaConversa,
          ),
        ],
      ),
      body: id == null
          ? _EmptyState(onCriar: _criarNovaConversa)
          : _ConversaBody(
              conversaId: id,
              scroll: _scroll,
              onMensagemEnviada: _scrollParaFinal,
            ),
    );
  }
}

class _ConversaBody extends ConsumerWidget {
  const _ConversaBody({
    required this.conversaId,
    required this.scroll,
    required this.onMensagemEnviada,
  });

  final String conversaId;
  final ScrollController scroll;
  final VoidCallback onMensagemEnviada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatControllerProvider(conversaId));

    ref.listen(chatControllerProvider(conversaId), (prev, next) {
      if ((prev?.mensagens.length ?? 0) != next.mensagens.length) {
        onMensagemEnviada();
      }
    });

    return Column(
      children: [
        Expanded(
          child: state.carregando && state.mensagens.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.mensagens.isEmpty
                  ? const _ConversaVazia()
                  : ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: state.mensagens.length,
                      itemBuilder: (_, i) =>
                          BolhaMensagem(mensagem: state.mensagens[i]),
                    ),
        ),
        BarraEnvio(
          enviando: state.enviando,
          onEnviar: (texto) async {
            final ok = await ref
                .read(chatControllerProvider(conversaId).notifier)
                .enviar(texto);
            if (ok) {
              ref
                  .read(conversasControllerProvider.notifier)
                  .marcarAtividade(conversaId);
            }
            return ok;
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCriar});

  final VoidCallback onCriar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: AppCores.azul500,
            ),
            const SizedBox(height: 16),
            const Text(
              'Comece uma nova conversa com o Cadu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppCores.azulNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O assistente da UFBA está pronto para ajudar com '
              'eventos, agenda e dúvidas do dia a dia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppCores.neutro700),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCriar,
              icon: const Icon(Icons.add),
              label: const Text('Nova conversa'),
              style: FilledButton.styleFrom(
                backgroundColor: AppCores.azul500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversaVazia extends StatelessWidget {
  const _ConversaVazia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Mande a primeira mensagem para iniciar a conversa.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppCores.neutro700, fontSize: 15),
        ),
      ),
    );
  }
}
