import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(String email, String senha);

  Future<Either<Failure, Usuario>> cadastrar({
    required String email,
    required String senha,
    required String nome,
  });

  Future<Either<Failure, void>> recuperarSenha(String email);

  Future<Either<Failure, void>> logout();

  /// Emite o usuário atualmente autenticado (ou null) sempre que a
  /// sessão muda.
  Stream<Usuario?> sessionStream();
}
