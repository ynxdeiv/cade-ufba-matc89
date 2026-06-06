import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/perfil.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Perfil>> obter();
  Future<Either<Failure, Perfil>> atualizar(Perfil perfil);
}
