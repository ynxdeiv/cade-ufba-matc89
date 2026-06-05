import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Linha de metadado padrão da tela de detalhe: ícone à esquerda,
/// label cinza acima e valor em texto principal abaixo.
class LinhaMetadado extends StatelessWidget {
  const LinhaMetadado({
    super.key,
    required this.icone,
    required this.label,
    required this.valor,
  });

  final IconData icone;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppCores.azul500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppCores.neutro500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: AppCores.neutro900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
