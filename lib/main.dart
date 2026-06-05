import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/di.dart';
import 'config/env.dart';
import 'features/auth/data/services/manter_conectado_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // "Lembre de mim" desligado → sessão volátil: encerra logo no boot
  // para forçar login a cada abertura do app.
  final manter = await ManterConectadoService().ligado();
  if (!manter && Supabase.instance.client.auth.currentSession != null) {
    await Supabase.instance.client.auth.signOut();
  }

  setupDi();

  runApp(const ProviderScope(child: CadeUfbaApp()));
}
