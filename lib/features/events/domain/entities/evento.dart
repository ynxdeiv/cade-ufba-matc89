import 'package:freezed_annotation/freezed_annotation.dart';

part 'evento.freezed.dart';

@freezed
class Evento with _$Evento {
  const factory Evento({
    required String id,
    required String titulo,
    String? descricao,
    required DateTime inicio,
    DateTime? fim,
    String? local,
    String? responsavel,
    /// Postgres serializa o `interval` como "HH:MM:SS" — mantemos string
    /// pura aqui e formatamos só na UI.
    String? cargaHoraria,
    @Default(false) bool temCertificado,
    String? categoria,
    String? unidade,
    int? capacidade,
    String? linkExterno,
  }) = _Evento;
}
