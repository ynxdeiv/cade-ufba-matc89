import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario.freezed.dart';

@freezed
class Usuario with _$Usuario {
  const factory Usuario({
    required String id,
    required String email,
    String? nome,
    String? vinculo,
  }) = _Usuario;
}
