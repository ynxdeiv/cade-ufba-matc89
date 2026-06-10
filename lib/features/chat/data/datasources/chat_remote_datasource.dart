import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../config/env.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDatasource {
  ChatRemoteDatasource(this._client, this._dio);

  final sb.SupabaseClient _client;
  final Dio _dio;

  String get _functionsUrl => Env.functionsUrl;

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
    if (userId == null) throw const AuthException('Usuário não autenticado');
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

  /// Chama a edge function `cadu-chat` e devolve os chunks de texto da resposta.
  /// Emite cada fragmento `text` e `null` ao final (evento `done: true` — banco
  /// já atualizado).
  ///
  /// Usa POST não-streaming (lê o corpo SSE inteiro de uma vez) porque
  /// `ResponseType.stream` da Dio não é suportado no Flutter Web. Funciona em
  /// todas as plataformas; a resposta chega de uma vez em vez de token-a-token.
  Stream<String?> streamarMensagem({
    required String conversationId,
    required String conteudo,
  }) async* {
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) throw const AuthException('Usuário não autenticado');

    late final Response<String> response;
    try {
      response = await _dio.post<String>(
        '$_functionsUrl/cadu-chat',
        data: jsonEncode({'mensagem': conteudo, 'conversation_id': conversationId}),
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
    } on DioException catch (e) {
      throw ServerException(_mensagemErroDio(e));
    }

    final corpo = response.data ?? '';
    for (final line in corpo.split('\n')) {
      if (!line.startsWith('data: ')) continue;
      final raw = line.substring(6).trim();
      if (raw.isEmpty || raw == '[DONE]') continue;

      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;

        if (json['done'] == true) {
          yield null; // sinaliza conclusão
          return;
        }

        final text = json['text'] as String?;
        if (text != null && text.isNotEmpty) yield text;
      } catch (_) {
        // chunk SSE malformado — ignora
      }
    }
  }

  String _mensagemErroDio(DioException e) {
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) {
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final erro = json['erro'] as String?;
        if (erro != null && erro.isNotEmpty) return erro;
      } catch (_) {}
    }
    return 'Cadu não conseguiu responder. Tente novamente.';
  }
}
