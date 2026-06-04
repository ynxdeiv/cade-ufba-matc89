import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Painel branco com bordas suaves usado dentro das telas de auth,
/// sobreposto ao [HeaderOndas]. Encapsula o padding e o título grande
/// estilo "BEM-VINDO" / "Login".
class PainelForm extends StatelessWidget {
  const PainelForm({
    super.key,
    required this.titulo,
    required this.children,
    this.alturaHeader = 320,
  });

  final String titulo;
  final List<Widget> children;
  final double alturaHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppCores.cinzaFundo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: AppCores.azulNavy,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}
