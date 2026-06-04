import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../widgets/botao_primario.dart';
import '../widgets/header_ondas.dart';

class BemVindoScreen extends StatelessWidget {
  const BemVindoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderOndas(altura: 360),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BEM-VINDO',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppCores.azulNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Conectando você aos eventos da UFBA, quando e onde quiser.',
                      style: TextStyle(
                        color: AppCores.cinzaTexto,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 260,
                        child: BotaoPrimario(
                          texto: 'Continuar',
                          iconeFim: Icons.arrow_forward,
                          onPressed: () => context.go('/login'),
                        ),
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
