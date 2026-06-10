import 'package:supabase_flutter/supabase_flutter.dart';
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
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Renomear conversa',
                                onPressed: () async {
                                  final controller = TextEditingController(text: c.titulo);

                                  try {
                                    final novoTitulo = await showDialog<String>(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: const Text('Renomear conversa'),
                                          content: TextField(
                                            controller: controller,
                                            maxLength: 60,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Digite o novo título',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(dialogContext).pop(),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final titulo = controller.text.trim();

                                                if (titulo.isEmpty) {
                                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'O título não pode ficar vazio.',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                if (titulo == c.titulo) {
                                                  Navigator.of(dialogContext).pop();
                                                  return;
                                                }

                                                Navigator.of(dialogContext).pop(titulo);
                                              },
                                              child: const Text('Salvar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (novoTitulo == null) return;

                                    await Supabase.instance.client
                                        .from('chat_conversations')
                                        .update({'titulo': novoTitulo})
                                        .eq('id', c.id);

                                    await ref
                                        .read(conversasControllerProvider.notifier)
                                        .carregar();

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Conversa renomeada com sucesso!'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Erro ao renomear conversa: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    controller.dispose();
                                  }
                                },
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
