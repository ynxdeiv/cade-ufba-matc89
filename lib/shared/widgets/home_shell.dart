import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_ShellTab>[
    _ShellTab(rota: '/home/eventos', icone: Icons.event, label: 'Eventos'),
    _ShellTab(rota: '/home/agenda', icone: Icons.calendar_today, label: 'Agenda'),
    _ShellTab(rota: '/home/chat', icone: Icons.chat_bubble_outline, label: 'Cadu'),
    _ShellTab(rota: '/home/perfil', icone: Icons.person_outline, label: 'Perfil'),
  ];

  int _indiceAtual(BuildContext context) {
    final rotaAtual = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((t) => rotaAtual.startsWith(t.rota));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual(context),
        onDestinationSelected: (i) => context.go(_tabs[i].rota),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icone), label: t.label),
        ],
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({required this.rota, required this.icone, required this.label});
  final String rota;
  final IconData icone;
  final String label;
}
