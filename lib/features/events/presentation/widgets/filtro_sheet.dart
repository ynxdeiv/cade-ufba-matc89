import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/filtro_evento.dart';

/// Bottom sheet com os filtros avançados (unidade, certificado,
/// intervalo). Devolve um novo [FiltroEvento] (ou null se cancelar).
class FiltroSheet extends StatefulWidget {
  const FiltroSheet({super.key, required this.atual});

  final FiltroEvento atual;

  static Future<FiltroEvento?> mostrar(
    BuildContext context, {
    required FiltroEvento atual,
  }) {
    return showModalBottomSheet<FiltroEvento>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FiltroSheet(atual: atual),
    );
  }

  @override
  State<FiltroSheet> createState() => _FiltroSheetState();
}

class _FiltroSheetState extends State<FiltroSheet> {
  late String? _unidade;
  late bool? _certificado;
  late DateTime? _inicio;
  late DateTime? _fim;

  static const _unidades = [
    'IME', 'IC', 'FACED', 'IHAC', 'ICS', 'IGEO', 'FAUFBA',
    'Escola Politécnica', 'Instituto de Letras', 'Reitoria',
    'Escola de Música', 'FDUFBA',
  ];

  @override
  void initState() {
    super.initState();
    _unidade = widget.atual.unidade;
    _certificado = widget.atual.temCertificado;
    _inicio = widget.atual.inicio;
    _fim = widget.atual.fim;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppCores.azulNavy,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: _unidade,
            decoration: const InputDecoration(labelText: 'Unidade'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              for (final u in _unidades)
                DropdownMenuItem(value: u, child: Text(u)),
            ],
            onChanged: (v) => setState(() => _unidade = v),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Apenas com certificado'),
            value: _certificado ?? false,
            onChanged: (v) => setState(() => _certificado = v ? true : null),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BotaoData(
                  label: 'De',
                  valor: _inicio,
                  onPick: (d) => setState(() => _inicio = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BotaoData(
                  label: 'Até',
                  valor: _fim,
                  onPick: (d) => setState(() => _fim = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.atual.copyWith(
                        unidade: null,
                        temCertificado: null,
                        inicio: null,
                        fim: null,
                      ),
                    );
                  },
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.atual.copyWith(
                        unidade: _unidade,
                        temCertificado: _certificado,
                        inicio: _inicio,
                        fim: _fim,
                      ),
                    );
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotaoData extends StatelessWidget {
  const _BotaoData({
    required this.label,
    required this.valor,
    required this.onPick,
  });

  final String label;
  final DateTime? valor;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final texto = valor == null
        ? label
        : '${valor!.day.toString().padLeft(2, '0')}/'
            '${valor!.month.toString().padLeft(2, '0')}/'
            '${valor!.year}';
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text(texto),
      onPressed: () async {
        final agora = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: agora.subtract(const Duration(days: 365)),
          lastDate: agora.add(const Duration(days: 365)),
          initialDate: valor ?? agora,
        );
        onPick(picked);
      },
    );
  }
}
