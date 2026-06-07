import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../models/perfil_model.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource(this._client);

  final sb.SupabaseClient _client;

  String _exigirUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('Usuário não autenticado');
    }
    return id;
  }

  Future<PerfilModel> obter() async {
    final userId = _exigirUserId();
    try {
      final row = await _client
          .from('profiles')
          .select('id, nome, vinculo, curso_departamento, foto_url')
          .eq('id', userId)
          .single();
      return PerfilModel.fromJson(row);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }

  Future<PerfilModel> atualizar(PerfilModel model) async {
    final userId = _exigirUserId();
    try {
      final row = await _client
          .from('profiles')
          .update(model.toUpdatePayload())
          .eq('id', userId)
          .select('id, nome, vinculo, curso_departamento, foto_url')
          .single();
      return PerfilModel.fromJson(row);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }
}
