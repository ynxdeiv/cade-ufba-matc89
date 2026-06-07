// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Perfil {
  String get id => throw _privateConstructorUsedError;
  String? get nome => throw _privateConstructorUsedError;
  VinculoUsuario? get vinculo => throw _privateConstructorUsedError;
  String? get cursoDepartamento => throw _privateConstructorUsedError;
  String? get fotoUrl => throw _privateConstructorUsedError;

  /// Create a copy of Perfil
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerfilCopyWith<Perfil> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerfilCopyWith<$Res> {
  factory $PerfilCopyWith(Perfil value, $Res Function(Perfil) then) =
      _$PerfilCopyWithImpl<$Res, Perfil>;
  @useResult
  $Res call({
    String id,
    String? nome,
    VinculoUsuario? vinculo,
    String? cursoDepartamento,
    String? fotoUrl,
  });
}

/// @nodoc
class _$PerfilCopyWithImpl<$Res, $Val extends Perfil>
    implements $PerfilCopyWith<$Res> {
  _$PerfilCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Perfil
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = freezed,
    Object? vinculo = freezed,
    Object? cursoDepartamento = freezed,
    Object? fotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nome: freezed == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String?,
            vinculo: freezed == vinculo
                ? _value.vinculo
                : vinculo // ignore: cast_nullable_to_non_nullable
                      as VinculoUsuario?,
            cursoDepartamento: freezed == cursoDepartamento
                ? _value.cursoDepartamento
                : cursoDepartamento // ignore: cast_nullable_to_non_nullable
                      as String?,
            fotoUrl: freezed == fotoUrl
                ? _value.fotoUrl
                : fotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PerfilImplCopyWith<$Res> implements $PerfilCopyWith<$Res> {
  factory _$$PerfilImplCopyWith(
    _$PerfilImpl value,
    $Res Function(_$PerfilImpl) then,
  ) = __$$PerfilImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? nome,
    VinculoUsuario? vinculo,
    String? cursoDepartamento,
    String? fotoUrl,
  });
}

/// @nodoc
class __$$PerfilImplCopyWithImpl<$Res>
    extends _$PerfilCopyWithImpl<$Res, _$PerfilImpl>
    implements _$$PerfilImplCopyWith<$Res> {
  __$$PerfilImplCopyWithImpl(
    _$PerfilImpl _value,
    $Res Function(_$PerfilImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Perfil
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = freezed,
    Object? vinculo = freezed,
    Object? cursoDepartamento = freezed,
    Object? fotoUrl = freezed,
  }) {
    return _then(
      _$PerfilImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nome: freezed == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String?,
        vinculo: freezed == vinculo
            ? _value.vinculo
            : vinculo // ignore: cast_nullable_to_non_nullable
                  as VinculoUsuario?,
        cursoDepartamento: freezed == cursoDepartamento
            ? _value.cursoDepartamento
            : cursoDepartamento // ignore: cast_nullable_to_non_nullable
                  as String?,
        fotoUrl: freezed == fotoUrl
            ? _value.fotoUrl
            : fotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PerfilImpl implements _Perfil {
  const _$PerfilImpl({
    required this.id,
    this.nome,
    this.vinculo,
    this.cursoDepartamento,
    this.fotoUrl,
  });

  @override
  final String id;
  @override
  final String? nome;
  @override
  final VinculoUsuario? vinculo;
  @override
  final String? cursoDepartamento;
  @override
  final String? fotoUrl;

  @override
  String toString() {
    return 'Perfil(id: $id, nome: $nome, vinculo: $vinculo, cursoDepartamento: $cursoDepartamento, fotoUrl: $fotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerfilImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.vinculo, vinculo) || other.vinculo == vinculo) &&
            (identical(other.cursoDepartamento, cursoDepartamento) ||
                other.cursoDepartamento == cursoDepartamento) &&
            (identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nome, vinculo, cursoDepartamento, fotoUrl);

  /// Create a copy of Perfil
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerfilImplCopyWith<_$PerfilImpl> get copyWith =>
      __$$PerfilImplCopyWithImpl<_$PerfilImpl>(this, _$identity);
}

abstract class _Perfil implements Perfil {
  const factory _Perfil({
    required final String id,
    final String? nome,
    final VinculoUsuario? vinculo,
    final String? cursoDepartamento,
    final String? fotoUrl,
  }) = _$PerfilImpl;

  @override
  String get id;
  @override
  String? get nome;
  @override
  VinculoUsuario? get vinculo;
  @override
  String? get cursoDepartamento;
  @override
  String? get fotoUrl;

  /// Create a copy of Perfil
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerfilImplCopyWith<_$PerfilImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
