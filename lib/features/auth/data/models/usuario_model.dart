import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/usuario.dart';

/// Wrapper de conversão entre [sb.User] e [Usuario]. Mantemos no schema
/// data para impedir que código de domain/presentation conheça o tipo
/// do supabase_flutter.
class UsuarioModel {
  const UsuarioModel({
    required this.id,
    required this.email,
    this.nome,
    this.vinculo,
  });

  factory UsuarioModel.deSbUser(sb.User user) {
    final meta = user.userMetadata ?? const {};
    return UsuarioModel(
      id: user.id,
      email: user.email ?? '',
      nome: meta['nome'] as String?,
      vinculo: meta['vinculo'] as String?,
    );
  }

  final String id;
  final String email;
  final String? nome;
  final String? vinculo;

  Usuario toEntity() => Usuario(
        id: id,
        email: email,
        nome: nome,
        vinculo: vinculo,
      );
}
