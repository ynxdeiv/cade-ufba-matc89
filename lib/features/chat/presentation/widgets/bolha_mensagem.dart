import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';

class BolhaMensagem extends StatelessWidget {
  const BolhaMensagem({super.key, required this.mensagem});

  final ChatMessage mensagem;

  @override
  Widget build(BuildContext context) {
    final ehUsuario = mensagem.role == ChatRole.user;
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
        child: Text(
          mensagem.conteudo,
          style: TextStyle(color: corTexto, fontSize: 15, height: 1.35),
        ),
      ),
    );
  }
}
