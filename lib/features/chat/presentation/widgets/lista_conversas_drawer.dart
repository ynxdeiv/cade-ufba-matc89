import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/chat_providers.dart';

class ListaConversasDrawer extends ConsumerWidget {
  const ListaConversasDrawer({super.key, required this.conversaAtivaId});

  final String? conversaAtivaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversasControllerProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Conversas',
                      style: TextStyle(
                        color: AppCores.azulNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Nova conversa',
                    icon: const Icon(Icons.add_comment_outlined),
                    onPressed: () async {
                      final id = await ref
                          .read(conversasControllerProvider.notifier)
                          .criar();
                      if (id != null && context.mounted) {
                        Navigator.of(context).pop();
                        context.go('/home/chat?conversa=$id');
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : state.conversas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhuma conversa ainda. Toque em + para começar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppCores.neutro700),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.conversas.length,
                          itemBuilder: (_, i) {
                            final c = state.conversas[i];
                            final ativa = c.id == conversaAtivaId;
                            return ListTile(
                              selected: ativa,
                              selectedTileColor: AppCores.azul100,
                              leading: const Icon(Icons.chat_bubble_outline),
                              title: Text(
                                c.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.go('/home/chat?conversa=${c.id}');
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
