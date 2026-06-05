import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/event_list_provider.dart';
import '../widgets/card_evento.dart';
import '../widgets/chip_categoria.dart';
import '../widgets/filtro_sheet.dart';

class ListaEventosScreen extends ConsumerStatefulWidget {
  const ListaEventosScreen({super.key});

  @override
  ConsumerState<ListaEventosScreen> createState() => _ListaEventosScreenState();
}

class _ListaEventosScreenState extends ConsumerState<ListaEventosScreen> {
  final _scroll = ScrollController();
  final _busca = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_aoRolar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventListControllerProvider.notifier).carregarPrimeiraPagina();
    });
  }

  void _aoRolar() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 240) {
      ref.read(eventListControllerProvider.notifier).carregarProximaPagina();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_aoRolar);
    _scroll.dispose();
    _busca.dispose();
    super.dispose();
  }

  Future<void> _abrirFiltro() async {
    final atual = ref.read(eventListControllerProvider).filtro;
    final novo = await FiltroSheet.mostrar(context, atual: atual);
    if (novo != null) {
      ref.read(eventListControllerProvider.notifier).aplicarFiltro(novo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventListControllerProvider);
    final controller = ref.read(eventListControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppCores.neutro100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.carregarPrimeiraPagina,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: AppCores.azul900,
                expandedHeight: 132,
                title: const Text(
                  'Eventos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Filtros',
                    onPressed: _abrirFiltro,
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        controller: _busca,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.atualizarBusca,
                        style: const TextStyle(color: AppCores.neutro900),
                        decoration: InputDecoration(
                          hintText: 'Buscar eventos...',
                          hintStyle:
                              const TextStyle(color: AppCores.neutro500),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppCores.neutro500,
                          ),
                          filled: true,
                          fillColor: AppCores.neutro0,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ChipsCategoria(
                    selecionada: state.filtro.categoria,
                    onSelecionar: controller.alternarCategoria,
                  ),
                ),
              ),
              if (state.servindoDoCache)
                const SliverToBoxAdapter(child: _BannerOffline()),
              ..._buildConteudo(state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConteudo(EventListState s) {
    if (s.carregandoInicial) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (s.eventos.isEmpty && s.erro != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            mensagem: _mensagemFalha(s.erro!),
            onRetry: () => ref
                .read(eventListControllerProvider.notifier)
                .carregarPrimeiraPagina(),
          ),
        ),
      ];
    }
    if (s.eventos.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'Nenhum evento encontrado.',
              style: TextStyle(color: AppCores.neutro500),
            ),
          ),
        ),
      ];
    }

    return [
      SliverList.builder(
        itemCount: s.eventos.length,
        itemBuilder: (_, i) => CardEvento(evento: s.eventos[i]),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: s.carregandoMais
                ? const CircularProgressIndicator()
                : Text(
                    s.fim ? 'Fim da lista' : '',
                    style: const TextStyle(color: AppCores.neutro500),
                  ),
          ),
        ),
      ),
    ];
  }

  String _mensagemFalha(Failure f) {
    if (f is NetworkFailure) {
      return 'Sem conexão. Verifique sua internet e tente de novo.';
    }
    if (f is ServerFailure) {
      return 'Não consegui carregar os eventos. Tente novamente.';
    }
    return f.mensagem ?? 'Algo deu errado.';
  }
}

class _BannerOffline extends StatelessWidget {
  const _BannerOffline();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppCores.azul50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Icon(Icons.cloud_off, size: 16, color: AppCores.azul700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você está vendo eventos salvos (sem conexão).',
              style: TextStyle(color: AppCores.azul700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
