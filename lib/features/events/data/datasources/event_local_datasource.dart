import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/evento_model.dart';

/// Cache offline simples para a primeira página da listagem neutra
/// (sem filtros). Atende ao critério "Sem conexão: primeira página é
/// cacheada para offline" da FE-004 sem custos de codegen (usamos
/// Box<String> + JSON).
class EventLocalDatasource {
  static const _boxName = 'events_cache';
  static const _primeiraPaginaKey = 'first_page';

  Future<Box<String>> _abrir() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    return Hive.openBox<String>(_boxName);
  }

  Future<void> salvarPrimeiraPagina(List<EventoModel> eventos) async {
    final box = await _abrir();
    final payload = eventos.map((e) => e.toJson()).toList();
    await box.put(_primeiraPaginaKey, jsonEncode(payload));
  }

  Future<List<EventoModel>> recuperarPrimeiraPagina() async {
    final box = await _abrir();
    final raw = box.get(_primeiraPaginaKey);
    if (raw == null) return const [];
    final lista = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return lista.map(EventoModel.fromJson).toList(growable: false);
  }
}
