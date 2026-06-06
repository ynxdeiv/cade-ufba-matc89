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
    this.cursoDepartamento,
    this.fotoUrl,
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

  /// Mescla os dados vindos de `auth.users` com os campos editáveis de
  /// `public.profiles`. A linha de `profiles` é a fonte da verdade.
  UsuarioModel mesclarComProfile(Map<String, dynamic> profile) {
    return UsuarioModel(
      id: id,
      email: email,
      nome: (profile['nome'] as String?) ?? nome,
      vinculo: (profile['vinculo'] as String?) ?? vinculo,
      cursoDepartamento: profile['curso_departamento'] as String?,
      fotoUrl: profile['foto_url'] as String?,
    );
  }

  final String id;
  final String email;
  final String? nome;
  final String? vinculo;
  final String? cursoDepartamento;
  final String? fotoUrl;

  Usuario toEntity() => Usuario(
        id: id,
        email: email,
        nome: nome,
        vinculo: vinculo,
        cursoDepartamento: cursoDepartamento,
        fotoUrl: fotoUrl,
      );
}
