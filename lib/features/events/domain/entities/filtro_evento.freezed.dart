// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filtro_evento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FiltroEvento {
  String? get busca => throw _privateConstructorUsedError;
  String? get categoria => throw _privateConstructorUsedError;
  String? get unidade => throw _privateConstructorUsedError;
  bool? get temCertificado => throw _privateConstructorUsedError;
  DateTime? get inicio => throw _privateConstructorUsedError;
  DateTime? get fim => throw _privateConstructorUsedError;

  /// Create a copy of FiltroEvento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FiltroEventoCopyWith<FiltroEvento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FiltroEventoCopyWith<$Res> {
  factory $FiltroEventoCopyWith(
    FiltroEvento value,
    $Res Function(FiltroEvento) then,
  ) = _$FiltroEventoCopyWithImpl<$Res, FiltroEvento>;
  @useResult
  $Res call({
    String? busca,
    String? categoria,
    String? unidade,
    bool? temCertificado,
    DateTime? inicio,
    DateTime? fim,
  });
}

/// @nodoc
class _$FiltroEventoCopyWithImpl<$Res, $Val extends FiltroEvento>
    implements $FiltroEventoCopyWith<$Res> {
  _$FiltroEventoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FiltroEvento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? busca = freezed,
    Object? categoria = freezed,
    Object? unidade = freezed,
    Object? temCertificado = freezed,
    Object? inicio = freezed,
    Object? fim = freezed,
  }) {
    return _then(
      _value.copyWith(
            busca: freezed == busca
                ? _value.busca
                : busca // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoria: freezed == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String?,
            unidade: freezed == unidade
                ? _value.unidade
                : unidade // ignore: cast_nullable_to_non_nullable
                      as String?,
            temCertificado: freezed == temCertificado
                ? _value.temCertificado
                : temCertificado // ignore: cast_nullable_to_non_nullable
                      as bool?,
            inicio: freezed == inicio
                ? _value.inicio
                : inicio // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            fim: freezed == fim
                ? _value.fim
                : fim // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FiltroEventoImplCopyWith<$Res>
    implements $FiltroEventoCopyWith<$Res> {
  factory _$$FiltroEventoImplCopyWith(
    _$FiltroEventoImpl value,
    $Res Function(_$FiltroEventoImpl) then,
  ) = __$$FiltroEventoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? busca,
    String? categoria,
    String? unidade,
    bool? temCertificado,
    DateTime? inicio,
    DateTime? fim,
  });
}

/// @nodoc
class __$$FiltroEventoImplCopyWithImpl<$Res>
    extends _$FiltroEventoCopyWithImpl<$Res, _$FiltroEventoImpl>
    implements _$$FiltroEventoImplCopyWith<$Res> {
  __$$FiltroEventoImplCopyWithImpl(
    _$FiltroEventoImpl _value,
    $Res Function(_$FiltroEventoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FiltroEvento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? busca = freezed,
    Object? categoria = freezed,
    Object? unidade = freezed,
    Object? temCertificado = freezed,
    Object? inicio = freezed,
    Object? fim = freezed,
  }) {
    return _then(
      _$FiltroEventoImpl(
        busca: freezed == busca
            ? _value.busca
            : busca // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoria: freezed == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String?,
        unidade: freezed == unidade
            ? _value.unidade
            : unidade // ignore: cast_nullable_to_non_nullable
                  as String?,
        temCertificado: freezed == temCertificado
            ? _value.temCertificado
            : temCertificado // ignore: cast_nullable_to_non_nullable
                  as bool?,
        inicio: freezed == inicio
            ? _value.inicio
            : inicio // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        fim: freezed == fim
            ? _value.fim
            : fim // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$FiltroEventoImpl extends _FiltroEvento {
  const _$FiltroEventoImpl({
    this.busca,
    this.categoria,
    this.unidade,
    this.temCertificado,
    this.inicio,
    this.fim,
  }) : super._();

  @override
  final String? busca;
  @override
  final String? categoria;
  @override
  final String? unidade;
  @override
  final bool? temCertificado;
  @override
  final DateTime? inicio;
  @override
  final DateTime? fim;

  @override
  String toString() {
    return 'FiltroEvento(busca: $busca, categoria: $categoria, unidade: $unidade, temCertificado: $temCertificado, inicio: $inicio, fim: $fim)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FiltroEventoImpl &&
            (identical(other.busca, busca) || other.busca == busca) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.unidade, unidade) || other.unidade == unidade) &&
            (identical(other.temCertificado, temCertificado) ||
                other.temCertificado == temCertificado) &&
            (identical(other.inicio, inicio) || other.inicio == inicio) &&
            (identical(other.fim, fim) || other.fim == fim));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    busca,
    categoria,
    unidade,
    temCertificado,
    inicio,
    fim,
  );

  /// Create a copy of FiltroEvento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FiltroEventoImplCopyWith<_$FiltroEventoImpl> get copyWith =>
      __$$FiltroEventoImplCopyWithImpl<_$FiltroEventoImpl>(this, _$identity);
}

abstract class _FiltroEvento extends FiltroEvento {
  const factory _FiltroEvento({
    final String? busca,
    final String? categoria,
    final String? unidade,
    final bool? temCertificado,
    final DateTime? inicio,
    final DateTime? fim,
  }) = _$FiltroEventoImpl;
  const _FiltroEvento._() : super._();

  @override
  String? get busca;
  @override
  String? get categoria;
  @override
  String? get unidade;
  @override
  bool? get temCertificado;
  @override
  DateTime? get inicio;
  @override
  DateTime? get fim;

  /// Create a copy of FiltroEvento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FiltroEventoImplCopyWith<_$FiltroEventoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
