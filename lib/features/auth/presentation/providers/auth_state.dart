import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/usuario.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.idle() = Idle;
  const factory AuthState.loading() = Loading;
  const factory AuthState.autenticado(Usuario usuario) = Autenticado;
  const factory AuthState.emailEnviado() = EmailEnviado;
  const factory AuthState.cadastrado() = Cadastrado;
  const factory AuthState.erro(String mensagem, {String? campo}) = Erro;
}
