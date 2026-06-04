import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Botão estilo CTA azul-royal do mockup. Com `carregando=true` exibe
/// loader inline e bloqueia a interação.
class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
    this.iconeFim,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;
  final IconData? iconeFim;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: carregando ? null : onPressed,
      child: carregando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(texto),
                if (iconeFim != null) ...[
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(iconeFim, color: AppCores.azulRoyal, size: 18),
                  ),
                ],
              ],
            ),
    );
  }
}
