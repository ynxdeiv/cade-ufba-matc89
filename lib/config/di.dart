import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupDi() {
  getIt.registerLazySingleton<Dio>(Dio.new);
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}
