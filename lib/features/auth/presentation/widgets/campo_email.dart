import 'package:flutter/material.dart';

import '../../domain/usecases/validadores.dart';

/// Campo de email com validação em tempo real e mensagem inline pt-BR.
class CampoEmail extends StatefulWidget {
  const CampoEmail({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.hint = 'Seu email',
    this.erroExterno,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  /// Mensagem de erro vinda de fora (ex.: AuthFailure do servidor).
  final String? erroExterno;
  final ValueChanged<String>? onChanged;

  @override
  State<CampoEmail> createState() => _CampoEmailState();
}

class _CampoEmailState extends State<CampoEmail> {
  String? _erroLocal;
  bool _tocado = false;

  void _validar(String value) {
    setState(() {
      _erroLocal = _tocado ? Validadores.mensagemEmail(value) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final erro = widget.erroExterno ?? _erroLocal;
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: erro,
      ),
      onChanged: (v) {
        _validar(v);
        widget.onChanged?.call(v);
      },
      onEditingComplete: () {
        setState(() => _tocado = true);
        _validar(widget.controller.text);
      },
      validator: (v) => Validadores.mensagemEmail(v ?? ''),
    );
  }
}
