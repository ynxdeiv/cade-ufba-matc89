import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Cabeçalho com 3 "ondas" sobrepostas em azul-céu, azul-royal e
/// azul-navy, alinhado com o mockup de auth. Pode ser usado como
/// `Stack` topo nas telas de autenticação.
class HeaderOndas extends StatelessWidget {
  const HeaderOndas({super.key, this.altura = 320});

  final double altura;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _OndasPainter(),
          ),
          Padding(
            padding: EdgeInsets.only(top: altura * 0.12),
            child: Image.asset(
              'assets/images/ufba_logo.png',
              height: altura * 0.55,
              fit: BoxFit.contain,
              semanticLabel: 'Brasão da UFBA',
            ),
          ),
        ],
      ),
    );
  }
}

class _OndasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Faixa de fundo azul-céu cobrindo todo o cabeçalho.
    final ceu = Paint()..color = AppCores.azulCeu;
    canvas.drawRect(Offset.zero & size, ceu);

    // 2. Onda azul-navy (dominante) — curva ampla cobrindo ~80% do
    //    cabeçalho.
    final navy = Paint()..color = AppCores.azulNavy;
    final pathNavy = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.45,
        size.width * 0.60,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.16,
        size.width,
        size.height * 0.32,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathNavy, navy);

    // 3. Onda azul-royal — faixa intermediária mais clara que cruza
    //    sobre o navy.
    final royal = Paint()..color = AppCores.azulRoyal;
    final pathRoyal = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.55,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.52,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height * 0.70)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.58,
        size.width * 0.50,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.78,
        0,
        size.height * 0.62,
      )
      ..close();
    canvas.drawPath(pathRoyal, royal);

    // 4. Onda inferior do navy — cria a transição curva para o fundo
    //    cinza da tela.
    final navyFundo = Paint()..color = AppCores.azulNavy;
    final pathFundo = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 1.05,
        size.width * 0.60,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.76,
        size.width,
        size.height * 0.90,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFundo, navyFundo);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
