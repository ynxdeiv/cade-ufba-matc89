import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Lista horizontal de chips das categorias do seed. Selecionar
/// alterna o filtro de categoria no controller.
class ChipsCategoria extends StatelessWidget {
  const ChipsCategoria({
    super.key,
    required this.selecionada,
    required this.onSelecionar,
  });

  /// Categoria atualmente selecionada (null = "Todos").
  final String? selecionada;
  final ValueChanged<String?> onSelecionar;

  static const _categorias = <_Cat>[
    _Cat('palestra', 'Palestras'),
    _Cat('minicurso', 'Minicursos'),
    _Cat('congresso', 'Congressos'),
    _Cat('defesa', 'Defesas'),
    _Cat('cultural', 'Culturais'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorias.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return ChoiceChip(
              label: const Text('Todos'),
              selected: selecionada == null,
              onSelected: (_) => onSelecionar(null),
              selectedColor: AppCores.azulRoyal,
              labelStyle: TextStyle(
                color: selecionada == null ? Colors.white : AppCores.azulNavy,
                fontWeight: FontWeight.w600,
              ),
            );
          }
          final cat = _categorias[i - 1];
          final ativo = selecionada == cat.valor;
          return ChoiceChip(
            label: Text(cat.rotulo),
            selected: ativo,
            onSelected: (_) => onSelecionar(cat.valor),
            selectedColor: AppCores.azulRoyal,
            labelStyle: TextStyle(
              color: ativo ? Colors.white : AppCores.azulNavy,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _Cat {
  const _Cat(this.valor, this.rotulo);
  final String valor;
  final String rotulo;
}
