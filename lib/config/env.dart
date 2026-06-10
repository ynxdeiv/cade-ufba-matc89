class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const _customFunctionsUrl = String.fromEnvironment('FUNCTIONS_URL');
  static String get functionsUrl =>
      _customFunctionsUrl.isNotEmpty ? _customFunctionsUrl : '$supabaseUrl/functions/v1';
}
