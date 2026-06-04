import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';
import 'validadores.dart';

class RecuperarSenha implements UseCase<void, String> {
  RecuperarSenha(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(String email) async {
    final erro = Validadores.mensagemEmail(email);
    if (erro != null) {
      return Left(ValidationFailure('email', erro));
    }
    return _repository.recuperarSenha(email.trim());
  }
}
