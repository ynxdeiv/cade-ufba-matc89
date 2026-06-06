import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart' as core;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDatasource _remote;

  @override
  Future<Either<Failure, Usuario>> login(String email, String senha) async {
    try {
      final m = await _remote.entrar(email: email, senha: senha);
      final hidratado = await _remote.hidratarComProfile(m);
      return Right(hidratado.toEntity());
    } on core.AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on core.NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on core.ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, Usuario>> cadastrar({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      final m = await _remote.cadastrar(email: email, senha: senha, nome: nome);
      return Right(m.toEntity());
    } on core.AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on core.NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on core.ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, void>> recuperarSenha(String email) async {
    try {
      await _remote.recuperarSenha(email);
      return const Right(null);
    } on core.AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on core.ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.sair();
      return const Right(null);
    } on core.ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Stream<Usuario?> sessionStream() async* {
    final atual = _remote.sessaoAtual();
    if (atual == null) {
      yield null;
    } else {
      final hidratado = await _remote.hidratarComProfile(atual);
      yield hidratado.toEntity();
    }
    await for (final ev in _remote.onAuthStateChange()) {
      final user = ev.session?.user;
      if (user == null) {
        yield null;
      } else {
        final base = UsuarioModel.deSbUser(user);
        final hidratado = await _remote.hidratarComProfile(base);
        yield hidratado.toEntity();
      }
    }
  }
}
