import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/evento.dart';

class CardEvento extends StatelessWidget {
  const CardEvento({super.key, required this.evento, this.onTap});

  final Evento evento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BadgeData(quando: evento.inicio),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppCores.neutro900,
                          ),
                        ),
                        if (evento.unidade != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            evento.unidade!,
                            style: const TextStyle(
                              color: AppCores.neutro500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (evento.descricao != null) ...[
                const SizedBox(height: 12),
                Text(
                  evento.descricao!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppCores.neutro700,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (evento.local != null)
                    _Meta(icone: Icons.place_outlined, texto: evento.local!),
                  if (evento.cargaHoraria != null)
                    _Meta(
                      icone: Icons.schedule,
                      texto: _formatarCarga(evento.cargaHoraria!),
                    ),
                  if (evento.temCertificado)
                    const _Meta(
                      icone: Icons.verified_outlined,
                      texto: 'Certificado',
                    ),
                  if (evento.categoria != null)
                    _Meta(icone: Icons.label_outline, texto: evento.categoria!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeData extends StatelessWidget {
  const _BadgeData({required this.quando});
  final DateTime quando;

  @override
  Widget build(BuildContext context) {
    final local = quando.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = _meses[local.month - 1];
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppCores.azul500,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            dia,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            mes.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: AppCores.neutro700),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(color: AppCores.neutro700, fontSize: 12),
        ),
      ],
    );
  }
}

const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _formatarCarga(String hhmmss) {
  // "02:00:00" → "2h"; "01:30:00" → "1h30"
  final partes = hhmmss.split(':');
  if (partes.length < 2) return hhmmss;
  final h = int.tryParse(partes[0]) ?? 0;
  final m = int.tryParse(partes[1]) ?? 0;
  if (h == 0 && m == 0) return '';
  if (m == 0) return '${h}h';
  if (h == 0) return '${m}min';
  return '${h}h${m.toString().padLeft(2, '0')}';
}
