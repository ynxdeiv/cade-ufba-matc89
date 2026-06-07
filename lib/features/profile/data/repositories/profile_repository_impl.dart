import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/perfil_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDatasource _remote;

  @override
  Future<Either<Failure, Perfil>> obter() async {
    try {
      final m = await _remote.obter();
      return Right(m.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, Perfil>> atualizar(Perfil perfil) async {
    try {
      final m = await _remote.atualizar(PerfilModel.fromEntity(perfil));
      return Right(m.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }
}
