import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';
import 'validadores.dart';

class ParametrosLogin extends Equatable {
  const ParametrosLogin({required this.email, required this.senha});

  final String email;
  final String senha;

  @override
  List<Object?> get props => [email, senha];
}

class Login implements UseCase<Usuario, ParametrosLogin> {
  Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Usuario>> call(ParametrosLogin params) async {
    final erroEmail = Validadores.mensagemEmail(params.email);
    if (erroEmail != null) {
      return Left(ValidationFailure('email', erroEmail));
    }
    if (params.senha.isEmpty) {
      return const Left(ValidationFailure('senha', 'Informe sua senha'));
    }
    return _repository.login(params.email.trim(), params.senha);
  }
}
