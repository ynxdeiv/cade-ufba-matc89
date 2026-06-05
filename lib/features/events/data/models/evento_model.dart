import '../../domain/entities/evento.dart';

class EventoModel {
  const EventoModel({
    required this.id,
    required this.titulo,
    required this.inicio,
    this.descricao,
    this.fim,
    this.local,
    this.responsavel,
    this.cargaHoraria,
    this.temCertificado = false,
    this.categoria,
    this.unidade,
    this.capacidade,
    this.linkExterno,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) => EventoModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String?,
        inicio: DateTime.parse(json['inicio'] as String),
        fim: json['fim'] == null ? null : DateTime.parse(json['fim'] as String),
        local: json['local'] as String?,
        responsavel: json['responsavel'] as String?,
        cargaHoraria: json['carga_horaria'] as String?,
        temCertificado: (json['tem_certificado'] as bool?) ?? false,
        categoria: json['categoria'] as String?,
        unidade: json['unidade'] as String?,
        capacidade: json['capacidade'] as int?,
        linkExterno: json['link_externo'] as String?,
      );

  final String id;
  final String titulo;
  final String? descricao;
  final DateTime inicio;
  final DateTime? fim;
  final String? local;
  final String? responsavel;
  final String? cargaHoraria;
  final bool temCertificado;
  final String? categoria;
  final String? unidade;
  final int? capacidade;
  final String? linkExterno;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'inicio': inicio.toIso8601String(),
        'fim': fim?.toIso8601String(),
        'local': local,
        'responsavel': responsavel,
        'carga_horaria': cargaHoraria,
        'tem_certificado': temCertificado,
        'categoria': categoria,
        'unidade': unidade,
        'capacidade': capacidade,
        'link_externo': linkExterno,
      };

  Evento toEntity() => Evento(
        id: id,
        titulo: titulo,
        descricao: descricao,
        inicio: inicio,
        fim: fim,
        local: local,
        responsavel: responsavel,
        cargaHoraria: cargaHoraria,
        temCertificado: temCertificado,
        categoria: categoria,
        unidade: unidade,
        capacidade: capacidade,
        linkExterno: linkExterno,
      );
}
