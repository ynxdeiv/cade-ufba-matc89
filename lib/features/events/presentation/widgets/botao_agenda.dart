import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// CTA principal da tela de detalhe — alterna entre "Adicionar à
/// agenda" (estilo primário) e "Remover da agenda" (estilo outlined
/// com a cor de erro) conforme [naAgenda].
class BotaoAgenda extends StatelessWidget {
  const BotaoAgenda({
    super.key,
    required this.naAgenda,
    required this.carregando,
    required this.onPressed,
  });

  final bool naAgenda;
  final bool carregando;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (naAgenda) {
      return OutlinedButton.icon(
        onPressed: carregando ? null : onPressed,
        icon: carregando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppCores.vermelho600,
                ),
              )
            : const Icon(Icons.event_busy_outlined,
                color: AppCores.vermelho600),
        label: const Text('Remover da agenda'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppCores.vermelho600,
          side: const BorderSide(color: AppCores.vermelho600, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: carregando ? null : onPressed,
      icon: carregando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.event_available_outlined, color: Colors.white),
      label: const Text('Adicionar à agenda'),
    );
  }
}
