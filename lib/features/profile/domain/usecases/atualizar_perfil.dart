import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/perfil.dart';
import '../repositories/profile_repository.dart';

class AtualizarPerfil implements UseCase<Perfil, Perfil> {
  AtualizarPerfil(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Perfil>> call(Perfil params) {
    final nome = params.nome?.trim();
    if (nome != null && nome.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('nome', 'nome não pode ser vazio')),
      );
    }
    return _repository.atualizar(params);
  }
}
