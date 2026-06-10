import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';

class BolhaMensagem extends StatelessWidget {
  const BolhaMensagem({super.key, required this.mensagem});

  final ChatMessage mensagem;

  @override
  Widget build(BuildContext context) {
    final ehUsuario = mensagem.role == ChatRole.user;
    return _Bolha(ehUsuario: ehUsuario, texto: mensagem.conteudo);
  }
}

/// Bolha do assistente exibida enquanto o texto chega via streaming.
class BolhaStreaming extends StatelessWidget {
  const BolhaStreaming({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return _Bolha(
      ehUsuario: false,
      texto: texto,
      streaming: true,
    );
  }
}

class _Bolha extends StatelessWidget {
  const _Bolha({
    required this.ehUsuario,
    required this.texto,
    this.streaming = false,
  });

  final bool ehUsuario;
  final String texto;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    final cor = ehUsuario ? AppCores.azul500 : AppCores.neutro0;
    final corTexto = ehUsuario ? Colors.white : AppCores.neutro900;

    return Align(
      alignment: ehUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(ehUsuario ? 16 : 4),
            bottomRight: Radius.circular(ehUsuario ? 4 : 16),
          ),
          border: ehUsuario
              ? null
              : Border.all(color: AppCores.neutro300, width: 0.5),
        ),
        child: texto.isEmpty && streaming
            ? _IndicadorDigitando(cor: corTexto)
            : Text(
                texto,
                style: TextStyle(color: corTexto, fontSize: 15, height: 1.35),
              ),
      ),
    );
  }
}

class _IndicadorDigitando extends StatefulWidget {
  const _IndicadorDigitando({required this.cor});

  final Color cor;

  @override
  State<_IndicadorDigitando> createState() => _IndicadorDigitandoState();
}

class _IndicadorDigitandoState extends State<_IndicadorDigitando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(widget.cor),
          const SizedBox(width: 4),
          _dot(widget.cor),
          const SizedBox(width: 4),
          _dot(widget.cor),
        ],
      ),
    );
  }

  Widget _dot(Color cor) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
      );
}
