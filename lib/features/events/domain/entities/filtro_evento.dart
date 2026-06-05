import 'package:freezed_annotation/freezed_annotation.dart';

part 'filtro_evento.freezed.dart';

@freezed
class FiltroEvento with _$FiltroEvento {
  const FiltroEvento._();

  const factory FiltroEvento({
    String? busca,
    String? categoria,
    String? unidade,
    bool? temCertificado,
    DateTime? inicio,
    DateTime? fim,
  }) = _FiltroEvento;

  /// Sem filtros do usuário — usado pela primeira carga e como base
  /// para o cache offline (só cacheamos quando neutro).
  bool get neutro =>
      busca == null &&
      categoria == null &&
      unidade == null &&
      temCertificado == null &&
      inicio == null &&
      fim == null;
}
