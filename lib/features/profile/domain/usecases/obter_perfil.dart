import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/perfil.dart';
import '../repositories/profile_repository.dart';

class ObterPerfil implements UseCase<Perfil, NoParams> {
  ObterPerfil(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Perfil>> call(NoParams params) {
    return _repository.obter();
  }
}
