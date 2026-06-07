import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil.freezed.dart';

enum VinculoUsuario { discente, docente, externo }

extension VinculoUsuarioX on VinculoUsuario {
  String get valor => switch (this) {
        VinculoUsuario.discente => 'discente',
        VinculoUsuario.docente => 'docente',
        VinculoUsuario.externo => 'externo',
      };

  String get rotulo => switch (this) {
        VinculoUsuario.discente => 'Discente',
        VinculoUsuario.docente => 'Docente',
        VinculoUsuario.externo => 'Externo',
      };

  static VinculoUsuario? deValor(String? raw) => switch (raw) {
        'discente' => VinculoUsuario.discente,
        'docente' => VinculoUsuario.docente,
        'externo' => VinculoUsuario.externo,
        _ => null,
      };
}

@freezed
class Perfil with _$Perfil {
  const factory Perfil({
    required String id,
    String? nome,
    VinculoUsuario? vinculo,
    String? cursoDepartamento,
    String? fotoUrl,
  }) = _Perfil;
}
