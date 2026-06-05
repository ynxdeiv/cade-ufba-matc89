// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Evento {
  String get id => throw _privateConstructorUsedError;
  String get titulo => throw _privateConstructorUsedError;
  String? get descricao => throw _privateConstructorUsedError;
  DateTime get inicio => throw _privateConstructorUsedError;
  DateTime? get fim => throw _privateConstructorUsedError;
  String? get local => throw _privateConstructorUsedError;
  String? get responsavel => throw _privateConstructorUsedError;

  /// Postgres serializa o `interval` como "HH:MM:SS" — mantemos string
  /// pura aqui e formatamos só na UI.
  String? get cargaHoraria => throw _privateConstructorUsedError;
  bool get temCertificado => throw _privateConstructorUsedError;
  String? get categoria => throw _privateConstructorUsedError;
  String? get unidade => throw _privateConstructorUsedError;
  int? get capacidade => throw _privateConstructorUsedError;
  String? get linkExterno => throw _privateConstructorUsedError;

  /// Create a copy of Evento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventoCopyWith<Evento> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventoCopyWith<$Res> {
  factory $EventoCopyWith(Evento value, $Res Function(Evento) then) =
      _$EventoCopyWithImpl<$Res, Evento>;
  @useResult
  $Res call({
    String id,
    String titulo,
    String? descricao,
    DateTime inicio,
    DateTime? fim,
    String? local,
    String? responsavel,
    String? cargaHoraria,
    bool temCertificado,
    String? categoria,
    String? unidade,
    int? capacidade,
    String? linkExterno,
  });
}

/// @nodoc
class _$EventoCopyWithImpl<$Res, $Val extends Evento>
    implements $EventoCopyWith<$Res> {
  _$EventoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Evento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descricao = freezed,
    Object? inicio = null,
    Object? fim = freezed,
    Object? local = freezed,
    Object? responsavel = freezed,
    Object? cargaHoraria = freezed,
    Object? temCertificado = null,
    Object? categoria = freezed,
    Object? unidade = freezed,
    Object? capacidade = freezed,
    Object? linkExterno = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titulo: null == titulo
                ? _value.titulo
                : titulo // ignore: cast_nullable_to_non_nullable
                      as String,
            descricao: freezed == descricao
                ? _value.descricao
                : descricao // ignore: cast_nullable_to_non_nullable
                      as String?,
            inicio: null == inicio
                ? _value.inicio
                : inicio // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fim: freezed == fim
                ? _value.fim
                : fim // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            local: freezed == local
                ? _value.local
                : local // ignore: cast_nullable_to_non_nullable
                      as String?,
            responsavel: freezed == responsavel
                ? _value.responsavel
                : responsavel // ignore: cast_nullable_to_non_nullable
                      as String?,
            cargaHoraria: freezed == cargaHoraria
                ? _value.cargaHoraria
                : cargaHoraria // ignore: cast_nullable_to_non_nullable
                      as String?,
            temCertificado: null == temCertificado
                ? _value.temCertificado
                : temCertificado // ignore: cast_nullable_to_non_nullable
                      as bool,
            categoria: freezed == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String?,
            unidade: freezed == unidade
                ? _value.unidade
                : unidade // ignore: cast_nullable_to_non_nullable
                      as String?,
            capacidade: freezed == capacidade
                ? _value.capacidade
                : capacidade // ignore: cast_nullable_to_non_nullable
                      as int?,
            linkExterno: freezed == linkExterno
                ? _value.linkExterno
                : linkExterno // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventoImplCopyWith<$Res> implements $EventoCopyWith<$Res> {
  factory _$$EventoImplCopyWith(
    _$EventoImpl value,
    $Res Function(_$EventoImpl) then,
  ) = __$$EventoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titulo,
    String? descricao,
    DateTime inicio,
    DateTime? fim,
    String? local,
    String? responsavel,
    String? cargaHoraria,
    bool temCertificado,
    String? categoria,
    String? unidade,
    int? capacidade,
    String? linkExterno,
  });
}

/// @nodoc
class __$$EventoImplCopyWithImpl<$Res>
    extends _$EventoCopyWithImpl<$Res, _$EventoImpl>
    implements _$$EventoImplCopyWith<$Res> {
  __$$EventoImplCopyWithImpl(
    _$EventoImpl _value,
    $Res Function(_$EventoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Evento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descricao = freezed,
    Object? inicio = null,
    Object? fim = freezed,
    Object? local = freezed,
    Object? responsavel = freezed,
    Object? cargaHoraria = freezed,
    Object? temCertificado = null,
    Object? categoria = freezed,
    Object? unidade = freezed,
    Object? capacidade = freezed,
    Object? linkExterno = freezed,
  }) {
    return _then(
      _$EventoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titulo: null == titulo
            ? _value.titulo
            : titulo // ignore: cast_nullable_to_non_nullable
                  as String,
        descricao: freezed == descricao
            ? _value.descricao
            : descricao // ignore: cast_nullable_to_non_nullable
                  as String?,
        inicio: null == inicio
            ? _value.inicio
            : inicio // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fim: freezed == fim
            ? _value.fim
            : fim // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        local: freezed == local
            ? _value.local
            : local // ignore: cast_nullable_to_non_nullable
                  as String?,
        responsavel: freezed == responsavel
            ? _value.responsavel
            : responsavel // ignore: cast_nullable_to_non_nullable
                  as String?,
        cargaHoraria: freezed == cargaHoraria
            ? _value.cargaHoraria
            : cargaHoraria // ignore: cast_nullable_to_non_nullable
                  as String?,
        temCertificado: null == temCertificado
            ? _value.temCertificado
            : temCertificado // ignore: cast_nullable_to_non_nullable
                  as bool,
        categoria: freezed == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String?,
        unidade: freezed == unidade
            ? _value.unidade
            : unidade // ignore: cast_nullable_to_non_nullable
                  as String?,
        capacidade: freezed == capacidade
            ? _value.capacidade
            : capacidade // ignore: cast_nullable_to_non_nullable
                  as int?,
        linkExterno: freezed == linkExterno
            ? _value.linkExterno
            : linkExterno // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$EventoImpl implements _Evento {
  const _$EventoImpl({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.inicio,
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

  @override
  final String id;
  @override
  final String titulo;
  @override
  final String? descricao;
  @override
  final DateTime inicio;
  @override
  final DateTime? fim;
  @override
  final String? local;
  @override
  final String? responsavel;

  /// Postgres serializa o `interval` como "HH:MM:SS" — mantemos string
  /// pura aqui e formatamos só na UI.
  @override
  final String? cargaHoraria;
  @override
  @JsonKey()
  final bool temCertificado;
  @override
  final String? categoria;
  @override
  final String? unidade;
  @override
  final int? capacidade;
  @override
  final String? linkExterno;

  @override
  String toString() {
    return 'Evento(id: $id, titulo: $titulo, descricao: $descricao, inicio: $inicio, fim: $fim, local: $local, responsavel: $responsavel, cargaHoraria: $cargaHoraria, temCertificado: $temCertificado, categoria: $categoria, unidade: $unidade, capacidade: $capacidade, linkExterno: $linkExterno)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descricao, descricao) ||
                other.descricao == descricao) &&
            (identical(other.inicio, inicio) || other.inicio == inicio) &&
            (identical(other.fim, fim) || other.fim == fim) &&
            (identical(other.local, local) || other.local == local) &&
            (identical(other.responsavel, responsavel) ||
                other.responsavel == responsavel) &&
            (identical(other.cargaHoraria, cargaHoraria) ||
                other.cargaHoraria == cargaHoraria) &&
            (identical(other.temCertificado, temCertificado) ||
                other.temCertificado == temCertificado) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.unidade, unidade) || other.unidade == unidade) &&
            (identical(other.capacidade, capacidade) ||
                other.capacidade == capacidade) &&
            (identical(other.linkExterno, linkExterno) ||
                other.linkExterno == linkExterno));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titulo,
    descricao,
    inicio,
    fim,
    local,
    responsavel,
    cargaHoraria,
    temCertificado,
    categoria,
    unidade,
    capacidade,
    linkExterno,
  );

  /// Create a copy of Evento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventoImplCopyWith<_$EventoImpl> get copyWith =>
      __$$EventoImplCopyWithImpl<_$EventoImpl>(this, _$identity);
}

abstract class _Evento implements Evento {
  const factory _Evento({
    required final String id,
    required final String titulo,
    final String? descricao,
    required final DateTime inicio,
    final DateTime? fim,
    final String? local,
    final String? responsavel,
    final String? cargaHoraria,
    final bool temCertificado,
    final String? categoria,
    final String? unidade,
    final int? capacidade,
    final String? linkExterno,
  }) = _$EventoImpl;

  @override
  String get id;
  @override
  String get titulo;
  @override
  String? get descricao;
  @override
  DateTime get inicio;
  @override
  DateTime? get fim;
  @override
  String? get local;
  @override
  String? get responsavel;

  /// Postgres serializa o `interval` como "HH:MM:SS" — mantemos string
  /// pura aqui e formatamos só na UI.
  @override
  String? get cargaHoraria;
  @override
  bool get temCertificado;
  @override
  String? get categoria;
  @override
  String? get unidade;
  @override
  int? get capacidade;
  @override
  String? get linkExterno;

  /// Create a copy of Evento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventoImplCopyWith<_$EventoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
