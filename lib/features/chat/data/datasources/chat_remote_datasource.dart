import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDatasource {
  ChatRemoteDatasource(this._client);

  final sb.SupabaseClient _client;

  static const _respostaStub =
      'Em breve a IA responderá por aqui. Por enquanto, sou apenas um eco.';

  Future<List<ChatConversationModel>> listarConversas() async {
    try {
      final res = await _client.rpc('listar_conversas');
      final lista = (res as List).cast<Map<String, dynamic>>();
      return lista
          .map(ChatConversationModel.fromJson)
          .toList(growable: false);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }

  Future<ChatConversationModel> criarConversa() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Usuário não autenticado');
    }
    try {
      final row = await _client
          .from('chat_conversations')
          .insert({'user_id': userId})
          .select()
          .single();
      return ChatConversationModel.fromJson(row);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }

  Future<List<ChatMessageModel>> listarMensagens(String conversationId) async {
    try {
      final res = await _client.rpc(
        'listar_historico_chat',
        params: {'p_conversation_id': conversationId},
      );
      final lista = (res as List).cast<Map<String, dynamic>>();
      return lista.map(ChatMessageModel.fromJson).toList(growable: false);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }

  Future<List<ChatMessageModel>> enviarMensagem({
    required String conversationId,
    required String conteudo,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Usuário não autenticado');
    }
    try {
      final inseridas = await _client
          .from('chat_messages')
          .insert([
            {
              'user_id': userId,
              'conversation_id': conversationId,
              'role': 'user',
              'conteudo': conteudo,
            },
            {
              'user_id': userId,
              'conversation_id': conversationId,
              'role': 'assistant',
              'conteudo': _respostaStub,
            },
          ])
          .select();
      return (inseridas as List)
          .cast<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList(growable: false);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }
}
