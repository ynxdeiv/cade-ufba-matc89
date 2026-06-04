import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart' as core;
import '../models/usuario_model.dart';

/// Camada fina sobre [sb.GoTrueClient]. Converte exceções do
/// `supabase_flutter` em exceções do `core/errors`.
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final sb.SupabaseClient _client;

  Future<UsuarioModel> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      final user = res.user;
      if (user == null) {
        throw const core.AuthException('Não foi possível obter o usuário');
      }
      return UsuarioModel.deSbUser(user);
    } on sb.AuthException catch (e) {
      throw core.AuthException(_mensagemAmigavel(e));
    } catch (_) {
      throw const core.ServerException('Falha ao autenticar');
    }
  }

  Future<UsuarioModel> cadastrar({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome},
        emailRedirectTo: 'cadeufba://auth-callback',
      );
      final user = res.user;
      if (user == null) {
        throw const core.AuthException('Não foi possível concluir o cadastro');
      }
      return UsuarioModel.deSbUser(user);
    } on sb.AuthException catch (e) {
      throw core.AuthException(_mensagemAmigavel(e));
    } catch (_) {
      throw const core.ServerException('Falha ao criar conta');
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'cadeufba://auth-callback',
      );
    } on sb.AuthException catch (e) {
      throw core.AuthException(_mensagemAmigavel(e));
    } catch (_) {
      throw const core.ServerException('Falha ao enviar email de recuperação');
    }
  }

  Future<void> sair() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw const core.ServerException('Falha ao encerrar sessão');
    }
  }

  Stream<sb.AuthState> onAuthStateChange() => _client.auth.onAuthStateChange;

  UsuarioModel? sessaoAtual() {
    final user = _client.auth.currentUser;
    return user == null ? null : UsuarioModel.deSbUser(user);
  }

  /// Mensagens internas do Supabase em pt-BR. Mantemos genérica em login
  /// para não revelar se o problema foi email ou senha.
  String _mensagemAmigavel(sb.AuthException e) {
    final raw = e.message.toLowerCase();
    if (raw.contains('invalid login') || raw.contains('invalid credentials')) {
      return 'Email ou senha inválidos';
    }
    if (raw.contains('already registered') ||
        raw.contains('user already')) {
      return 'Este email já está cadastrado';
    }
    if (raw.contains('email not confirmed')) {
      return 'Confirme seu email antes de entrar';
    }
    if (raw.contains('password should be')) {
      return 'Senha não atende aos requisitos';
    }
    return e.message;
  }
}
