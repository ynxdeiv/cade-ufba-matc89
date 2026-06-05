import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/filtro_evento.dart';
import '../models/evento_model.dart';

class EventRemoteDatasource {
  EventRemoteDatasource(this._client);

  final sb.SupabaseClient _client;

  Future<List<EventoModel>> listar({
    required FiltroEvento filtro,
    required int limit,
    required int offset,
  }) async {
    // Quando o usuário não passa janela, abrimos uma ampla (hoje −7d a
    // hoje +180d) que cobre o seed e o caso típico de exploração.
    final hoje = DateTime.now().toUtc();
    final inicio = filtro.inicio ?? hoje.subtract(const Duration(days: 7));
    final fim = filtro.fim ?? hoje.add(const Duration(days: 180));

    final params = <String, dynamic>{
      'p_inicio': inicio.toIso8601String(),
      'p_fim': fim.toIso8601String(),
      'p_limit': limit,
      'p_offset': offset,
      if (filtro.categoria != null) 'p_categoria': filtro.categoria,
      if (filtro.unidade != null) 'p_unidade': filtro.unidade,
      if (filtro.busca != null && filtro.busca!.trim().isNotEmpty)
        'p_busca': filtro.busca!.trim(),
      if (filtro.temCertificado != null)
        'p_tem_certificado': filtro.temCertificado,
    };

    try {
      final res = await _client.rpc('listar_eventos', params: params);
      final lista = (res as List).cast<Map<String, dynamic>>();
      return lista.map(EventoModel.fromJson).toList(growable: false);
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    } on TimeoutException {
      throw const NetworkException('Tempo esgotado');
    } catch (_) {
      throw const NetworkException('Falha de conexão');
    }
  }
}
