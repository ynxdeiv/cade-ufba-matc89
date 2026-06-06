import '../../domain/entities/perfil.dart';

class PerfilModel {
  const PerfilModel({
    required this.id,
    this.nome,
    this.vinculo,
    this.cursoDepartamento,
    this.fotoUrl,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) => PerfilModel(
        id: json['id'] as String,
        nome: json['nome'] as String?,
        vinculo: json['vinculo'] as String?,
        cursoDepartamento: json['curso_departamento'] as String?,
        fotoUrl: json['foto_url'] as String?,
      );

  final String id;
  final String? nome;
  final String? vinculo;
  final String? cursoDepartamento;
  final String? fotoUrl;

  /// Payload para `update` em `public.profiles` — só os campos
  /// editáveis pelo usuário. Strings vazias viram null.
  Map<String, dynamic> toUpdatePayload() {
    String? norm(String? v) {
      if (v == null) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    return {
      'nome': norm(nome),
      'vinculo': vinculo,
      'curso_departamento': norm(cursoDepartamento),
      'foto_url': norm(fotoUrl),
    };
  }

  Perfil toEntity() => Perfil(
        id: id,
        nome: nome,
        vinculo: VinculoUsuarioX.deValor(vinculo),
        cursoDepartamento: cursoDepartamento,
        fotoUrl: fotoUrl,
      );

  static PerfilModel fromEntity(Perfil p) => PerfilModel(
        id: p.id,
        nome: p.nome,
        vinculo: p.vinculo?.valor,
        cursoDepartamento: p.cursoDepartamento,
        fotoUrl: p.fotoUrl,
      );
}
