// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
    _$IdleImpl value,
    $Res Function(_$IdleImpl) then,
  ) = __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
    : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'AuthState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class Idle implements AuthState {
  const factory Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class Loading implements AuthState {
  const factory Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AutenticadoImplCopyWith<$Res> {
  factory _$$AutenticadoImplCopyWith(
    _$AutenticadoImpl value,
    $Res Function(_$AutenticadoImpl) then,
  ) = __$$AutenticadoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Usuario usuario});

  $UsuarioCopyWith<$Res> get usuario;
}

/// @nodoc
class __$$AutenticadoImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AutenticadoImpl>
    implements _$$AutenticadoImplCopyWith<$Res> {
  __$$AutenticadoImplCopyWithImpl(
    _$AutenticadoImpl _value,
    $Res Function(_$AutenticadoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? usuario = null}) {
    return _then(
      _$AutenticadoImpl(
        null == usuario
            ? _value.usuario
            : usuario // ignore: cast_nullable_to_non_nullable
                  as Usuario,
      ),
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsuarioCopyWith<$Res> get usuario {
    return $UsuarioCopyWith<$Res>(_value.usuario, (value) {
      return _then(_value.copyWith(usuario: value));
    });
  }
}

/// @nodoc

class _$AutenticadoImpl implements Autenticado {
  const _$AutenticadoImpl(this.usuario);

  @override
  final Usuario usuario;

  @override
  String toString() {
    return 'AuthState.autenticado(usuario: $usuario)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutenticadoImpl &&
            (identical(other.usuario, usuario) || other.usuario == usuario));
  }

  @override
  int get hashCode => Object.hash(runtimeType, usuario);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutenticadoImplCopyWith<_$AutenticadoImpl> get copyWith =>
      __$$AutenticadoImplCopyWithImpl<_$AutenticadoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return autenticado(usuario);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return autenticado?.call(usuario);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (autenticado != null) {
      return autenticado(usuario);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return autenticado(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return autenticado?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (autenticado != null) {
      return autenticado(this);
    }
    return orElse();
  }
}

abstract class Autenticado implements AuthState {
  const factory Autenticado(final Usuario usuario) = _$AutenticadoImpl;

  Usuario get usuario;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutenticadoImplCopyWith<_$AutenticadoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailEnviadoImplCopyWith<$Res> {
  factory _$$EmailEnviadoImplCopyWith(
    _$EmailEnviadoImpl value,
    $Res Function(_$EmailEnviadoImpl) then,
  ) = __$$EmailEnviadoImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailEnviadoImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$EmailEnviadoImpl>
    implements _$$EmailEnviadoImplCopyWith<$Res> {
  __$$EmailEnviadoImplCopyWithImpl(
    _$EmailEnviadoImpl _value,
    $Res Function(_$EmailEnviadoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailEnviadoImpl implements EmailEnviado {
  const _$EmailEnviadoImpl();

  @override
  String toString() {
    return 'AuthState.emailEnviado()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EmailEnviadoImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return emailEnviado();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return emailEnviado?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (emailEnviado != null) {
      return emailEnviado();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return emailEnviado(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return emailEnviado?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (emailEnviado != null) {
      return emailEnviado(this);
    }
    return orElse();
  }
}

abstract class EmailEnviado implements AuthState {
  const factory EmailEnviado() = _$EmailEnviadoImpl;
}

/// @nodoc
abstract class _$$CadastradoImplCopyWith<$Res> {
  factory _$$CadastradoImplCopyWith(
    _$CadastradoImpl value,
    $Res Function(_$CadastradoImpl) then,
  ) = __$$CadastradoImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CadastradoImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$CadastradoImpl>
    implements _$$CadastradoImplCopyWith<$Res> {
  __$$CadastradoImplCopyWithImpl(
    _$CadastradoImpl _value,
    $Res Function(_$CadastradoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CadastradoImpl implements Cadastrado {
  const _$CadastradoImpl();

  @override
  String toString() {
    return 'AuthState.cadastrado()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CadastradoImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return cadastrado();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return cadastrado?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (cadastrado != null) {
      return cadastrado();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return cadastrado(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return cadastrado?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (cadastrado != null) {
      return cadastrado(this);
    }
    return orElse();
  }
}

abstract class Cadastrado implements AuthState {
  const factory Cadastrado() = _$CadastradoImpl;
}

/// @nodoc
abstract class _$$ErroImplCopyWith<$Res> {
  factory _$$ErroImplCopyWith(
    _$ErroImpl value,
    $Res Function(_$ErroImpl) then,
  ) = __$$ErroImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String mensagem, String? campo});
}

/// @nodoc
class __$$ErroImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ErroImpl>
    implements _$$ErroImplCopyWith<$Res> {
  __$$ErroImplCopyWithImpl(_$ErroImpl _value, $Res Function(_$ErroImpl) _then)
    : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mensagem = null, Object? campo = freezed}) {
    return _then(
      _$ErroImpl(
        null == mensagem
            ? _value.mensagem
            : mensagem // ignore: cast_nullable_to_non_nullable
                  as String,
        campo: freezed == campo
            ? _value.campo
            : campo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ErroImpl implements Erro {
  const _$ErroImpl(this.mensagem, {this.campo});

  @override
  final String mensagem;
  @override
  final String? campo;

  @override
  String toString() {
    return 'AuthState.erro(mensagem: $mensagem, campo: $campo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErroImpl &&
            (identical(other.mensagem, mensagem) ||
                other.mensagem == mensagem) &&
            (identical(other.campo, campo) || other.campo == campo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mensagem, campo);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErroImplCopyWith<_$ErroImpl> get copyWith =>
      __$$ErroImplCopyWithImpl<_$ErroImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(Usuario usuario) autenticado,
    required TResult Function() emailEnviado,
    required TResult Function() cadastrado,
    required TResult Function(String mensagem, String? campo) erro,
  }) {
    return erro(mensagem, campo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(Usuario usuario)? autenticado,
    TResult? Function()? emailEnviado,
    TResult? Function()? cadastrado,
    TResult? Function(String mensagem, String? campo)? erro,
  }) {
    return erro?.call(mensagem, campo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(Usuario usuario)? autenticado,
    TResult Function()? emailEnviado,
    TResult Function()? cadastrado,
    TResult Function(String mensagem, String? campo)? erro,
    required TResult orElse(),
  }) {
    if (erro != null) {
      return erro(mensagem, campo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Idle value) idle,
    required TResult Function(Loading value) loading,
    required TResult Function(Autenticado value) autenticado,
    required TResult Function(EmailEnviado value) emailEnviado,
    required TResult Function(Cadastrado value) cadastrado,
    required TResult Function(Erro value) erro,
  }) {
    return erro(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Idle value)? idle,
    TResult? Function(Loading value)? loading,
    TResult? Function(Autenticado value)? autenticado,
    TResult? Function(EmailEnviado value)? emailEnviado,
    TResult? Function(Cadastrado value)? cadastrado,
    TResult? Function(Erro value)? erro,
  }) {
    return erro?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Idle value)? idle,
    TResult Function(Loading value)? loading,
    TResult Function(Autenticado value)? autenticado,
    TResult Function(EmailEnviado value)? emailEnviado,
    TResult Function(Cadastrado value)? cadastrado,
    TResult Function(Erro value)? erro,
    required TResult orElse(),
  }) {
    if (erro != null) {
      return erro(this);
    }
    return orElse();
  }
}

abstract class Erro implements AuthState {
  const factory Erro(final String mensagem, {final String? campo}) = _$ErroImpl;

  String get mensagem;
  String? get campo;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErroImplCopyWith<_$ErroImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
