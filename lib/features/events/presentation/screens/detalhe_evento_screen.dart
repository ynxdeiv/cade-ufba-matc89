import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/evento.dart';
import '../providers/event_detail_provider.dart';
import '../widgets/botao_agenda.dart';
import '../widgets/linha_metadado.dart';

/// Tag única do Hero — usada também no CardEvento da listagem.
String heroTagEvento(String id) => 'evento-$id';

class DetalheEventoScreen extends ConsumerWidget {
  const DetalheEventoScreen({super.key, required this.eventoId});

  final String eventoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventoAsync = ref.watch(eventoPorIdProvider(eventoId));

    return Scaffold(
      backgroundColor: AppCores.neutro100,
      body: eventoAsync.when(
        loading: () => const _Carregando(),
        error: (e, _) => _Erro(
          mensagem: e.toString(),
          onRetry: () => ref.invalidate(eventoPorIdProvider(eventoId)),
        ),
        data: (evento) => _Conteudo(evento: evento),
      ),
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.mensagem, required this.onRetry});
  final String mensagem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ErrorView(mensagem: mensagem, onRetry: onRetry),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _voltar(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.evento});
  final Evento evento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(agendaProvider(evento.id));
    final agendaCtrl = ref.read(agendaProvider(evento.id).notifier);

    Future<void> alternarAgenda() async {
      final estavaNaAgenda = agenda.naAgenda;
      final ok = await agendaCtrl.alternar();
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              estavaNaAgenda
                  ? 'Evento removido da sua agenda'
                  : 'Evento adicionado à sua agenda',
            ),
          ),
        );
      } else if (ref.read(agendaProvider(evento.id)).erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(agendaProvider(evento.id)).erro ??
                  'Não foi possível atualizar a agenda',
            ),
          ),
        );
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppCores.azul900,
          foregroundColor: Colors.white,
          expandedHeight: 200,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _voltar(context),
          ),
          actions: [
            IconButton(
              tooltip: 'Compartilhar',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _compartilhar(evento),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _HeaderHero(evento: evento),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppCores.neutro900,
                    height: 1.2,
                  ),
                ),
                if (evento.categoria != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppCores.azul50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _capitalize(evento.categoria!),
                      style: const TextStyle(
                        color: AppCores.azul700,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (evento.descricao != null) ...[
                  Text(
                    evento.descricao!,
                    style: const TextStyle(
                      color: AppCores.neutro700,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Divider(),
                LinhaMetadado(
                  icone: Icons.event_outlined,
                  label: 'DATA E HORA',
                  valor: _formatarDataHora(evento),
                ),
                if (evento.local != null)
                  LinhaMetadado(
                    icone: Icons.place_outlined,
                    label: 'LOCAL',
                    valor: evento.local!,
                  ),
                if (evento.responsavel != null)
                  LinhaMetadado(
                    icone: Icons.person_outline,
                    label: 'RESPONSÁVEL',
                    valor: evento.responsavel!,
                  ),
                if (evento.cargaHoraria != null)
                  LinhaMetadado(
                    icone: Icons.schedule,
                    label: 'CARGA HORÁRIA',
                    valor: _formatarCarga(evento.cargaHoraria!),
                  ),
                if (evento.unidade != null)
                  LinhaMetadado(
                    icone: Icons.school_outlined,
                    label: 'UNIDADE',
                    valor: evento.unidade!,
                  ),
                if (evento.capacidade != null)
                  LinhaMetadado(
                    icone: Icons.groups_outlined,
                    label: 'CAPACIDADE',
                    valor: '${evento.capacidade} vagas',
                  ),
                LinhaMetadado(
                  icone: Icons.verified_outlined,
                  label: 'CERTIFICADO',
                  valor: evento.temCertificado ? 'Sim' : 'Não',
                ),
                if (evento.linkExterno != null)
                  LinhaMetadado(
                    icone: Icons.link,
                    label: 'INSCRIÇÃO/SAIBA MAIS',
                    valor: evento.linkExterno!,
                  ),
                const SizedBox(height: 24),
                BotaoAgenda(
                  naAgenda: agenda.naAgenda,
                  carregando: agenda.carregando,
                  onPressed: alternarAgenda,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({required this.evento});
  final Evento evento;

  @override
  Widget build(BuildContext context) {
    final local = evento.inicio.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    return Hero(
      tag: heroTagEvento(evento.id),
      child: Material(
        color: AppCores.azul900,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Faixa diagonal azul500 para dar profundidade — coerente
            // com o badge de data dos cards.
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppCores.azul700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppCores.azul500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dia,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            _meses[local.month - 1].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (evento.unidade != null)
                      Text(
                        evento.unidade!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

void _voltar(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home/eventos');
  }
}

Future<void> _compartilhar(Evento e) async {
  final local = e.inicio.toLocal();
  final data = '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} às '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  // Deep link interno (vai precisar do app_links + esquema cadeufba
  // configurado no Android/iOS para abrir o app — por ora a URL serve
  // como rastreio textual).
  final link = 'cadeufba://eventos/${e.id}';
  final texto = '${e.titulo}\n📅 $data\n$link';
  await Share.share(texto, subject: e.titulo);
}

const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _formatarDataHora(Evento e) {
  final inicio = e.inicio.toLocal();
  final inicioStr =
      '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')}/${inicio.year} '
      'às ${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}';
  if (e.fim == null) return inicioStr;
  final fim = e.fim!.toLocal();
  final mesmoDia = inicio.year == fim.year &&
      inicio.month == fim.month &&
      inicio.day == fim.day;
  if (mesmoDia) {
    return '$inicioStr — ${fim.hour.toString().padLeft(2, '0')}:'
        '${fim.minute.toString().padLeft(2, '0')}';
  }
  return '$inicioStr → '
      '${fim.day.toString().padLeft(2, '0')}/${fim.month.toString().padLeft(2, '0')} '
      '${fim.hour.toString().padLeft(2, '0')}:${fim.minute.toString().padLeft(2, '0')}';
}

String _formatarCarga(String hhmmss) {
  final p = hhmmss.split(':');
  if (p.length < 2) return hhmmss;
  final h = int.tryParse(p[0]) ?? 0;
  final m = int.tryParse(p[1]) ?? 0;
  if (h == 0 && m == 0) return hhmmss;
  if (m == 0) return '${h}h';
  if (h == 0) return '${m}min';
  return '${h}h${m.toString().padLeft(2, '0')}';
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
