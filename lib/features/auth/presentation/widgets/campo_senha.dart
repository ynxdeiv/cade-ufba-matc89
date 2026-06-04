import 'package:flutter/material.dart';

import '../../domain/usecases/validadores.dart';

/// Campo de senha com toggle de visibilidade. Quando `validarForca=true`
/// usa a regra completa (≥ 8 chars, 1 letra + 1 dígito); caso contrário
/// apenas exige preenchimento.
class CampoSenha extends StatefulWidget {
  const CampoSenha({
    super.key,
    required this.controller,
    this.label = 'Senha',
    this.hint = 'Sua senha',
    this.validarForca = false,
    this.erroExterno,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool validarForca;
  final String? erroExterno;
  final ValueChanged<String>? onChanged;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _visivel = false;
  String? _erroLocal;
  bool _tocado = false;

  String? _avaliar(String value) {
    if (widget.validarForca) return Validadores.mensagemSenha(value);
    if (value.isEmpty) return 'Informe sua senha';
    return null;
  }

  void _validar(String value) {
    setState(() {
      _erroLocal = _tocado ? _avaliar(value) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final erro = widget.erroExterno ?? _erroLocal;
    return TextFormField(
      controller: widget.controller,
      obscureText: !_visivel,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: erro,
        suffixIcon: IconButton(
          icon: Icon(_visivel ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _visivel = !_visivel),
          tooltip: _visivel ? 'Ocultar senha' : 'Mostrar senha',
        ),
      ),
      onChanged: (v) {
        _validar(v);
        widget.onChanged?.call(v);
      },
      onEditingComplete: () {
        setState(() => _tocado = true);
        _validar(widget.controller.text);
      },
      validator: (v) => _avaliar(v ?? ''),
    );
  }
}
