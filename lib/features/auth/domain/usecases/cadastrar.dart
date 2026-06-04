import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';
import 'validadores.dart';

class ParametrosCadastro extends Equatable {
  const ParametrosCadastro({
    required this.nome,
    required this.email,
    required this.senha,
  });

  final String nome;
  final String email;
  final String senha;

  @override
  List<Object?> get props => [nome, email, senha];
}

class Cadastrar implements UseCase<Usuario, ParametrosCadastro> {
  Cadastrar(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Usuario>> call(ParametrosCadastro params) async {
    final erroNome = Validadores.mensagemNome(params.nome);
    if (erroNome != null) {
      return Left(ValidationFailure('nome', erroNome));
    }
    final erroEmail = Validadores.mensagemEmail(params.email);
    if (erroEmail != null) {
      return Left(ValidationFailure('email', erroEmail));
    }
    final erroSenha = Validadores.mensagemSenha(params.senha);
    if (erroSenha != null) {
      return Left(ValidationFailure('senha', erroSenha));
    }
    return _repository.cadastrar(
      nome: params.nome.trim(),
      email: params.email.trim(),
      senha: params.senha,
    );
  }
}
