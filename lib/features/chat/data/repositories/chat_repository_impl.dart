import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<ChatConversation>>> listarConversas() async {
    try {
      final modelos = await _remote.listarConversas();
      return Right(modelos.map((m) => m.toEntity()).toList(growable: false));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> criarConversa() async {
    try {
      final modelo = await _remote.criarConversa();
      return Right(modelo.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> listarMensagens(
    String conversationId,
  ) async {
    try {
      final modelos = await _remote.listarMensagens(conversationId);
      return Right(modelos.map((m) => m.toEntity()).toList(growable: false));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.mensagem));
    }
  }

  @override
  Stream<Either<Failure, String>> streamarMensagem({
    required String conversationId,
    required String conteudo,
  }) async* {
    try {
      await for (final chunk
          in _remote.streamarMensagem(
            conversationId: conversationId,
            conteudo: conteudo,
          )) {
        if (chunk == null) return; // done
        yield Right(chunk);
      }
    } on AuthException catch (e) {
      yield Left(AuthFailure(e.mensagem));
    } on NetworkException catch (e) {
      yield Left(NetworkFailure(e.mensagem));
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.mensagem));
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }
}
