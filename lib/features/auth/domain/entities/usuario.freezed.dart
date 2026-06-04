// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Usuario {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get nome => throw _privateConstructorUsedError;
  String? get vinculo => throw _privateConstructorUsedError;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsuarioCopyWith<Usuario> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsuarioCopyWith<$Res> {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) then) =
      _$UsuarioCopyWithImpl<$Res, Usuario>;
  @useResult
  $Res call({String id, String email, String? nome, String? vinculo});
}

/// @nodoc
class _$UsuarioCopyWithImpl<$Res, $Val extends Usuario>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nome = freezed,
    Object? vinculo = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            nome: freezed == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String?,
            vinculo: freezed == vinculo
                ? _value.vinculo
                : vinculo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UsuarioImplCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$$UsuarioImplCopyWith(
    _$UsuarioImpl value,
    $Res Function(_$UsuarioImpl) then,
  ) = __$$UsuarioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String email, String? nome, String? vinculo});
}

/// @nodoc
class __$$UsuarioImplCopyWithImpl<$Res>
    extends _$UsuarioCopyWithImpl<$Res, _$UsuarioImpl>
    implements _$$UsuarioImplCopyWith<$Res> {
  __$$UsuarioImplCopyWithImpl(
    _$UsuarioImpl _value,
    $Res Function(_$UsuarioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nome = freezed,
    Object? vinculo = freezed,
  }) {
    return _then(
      _$UsuarioImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        nome: freezed == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String?,
        vinculo: freezed == vinculo
            ? _value.vinculo
            : vinculo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UsuarioImpl implements _Usuario {
  const _$UsuarioImpl({
    required this.id,
    required this.email,
    this.nome,
    this.vinculo,
  });

  @override
  final String id;
  @override
  final String email;
  @override
  final String? nome;
  @override
  final String? vinculo;

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, nome: $nome, vinculo: $vinculo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsuarioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.vinculo, vinculo) || other.vinculo == vinculo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, email, nome, vinculo);

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsuarioImplCopyWith<_$UsuarioImpl> get copyWith =>
      __$$UsuarioImplCopyWithImpl<_$UsuarioImpl>(this, _$identity);
}

abstract class _Usuario implements Usuario {
  const factory _Usuario({
    required final String id,
    required final String email,
    final String? nome,
    final String? vinculo,
  }) = _$UsuarioImpl;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get nome;
  @override
  String? get vinculo;

  /// Create a copy of Usuario
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsuarioImplCopyWith<_$UsuarioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
