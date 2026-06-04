import 'package:shared_preferences/shared_preferences.dart';

/// Controla a flag "manter conectado". Quando desligada, o app encerra
/// a sessão no próximo bootstrap (ver `main.dart`), tornando-a volátil
/// para esse usuário.
class ManterConectadoService {
  static const _chave = 'auth.manter_conectado';

  Future<bool> ligado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chave) ?? false;
  }

  Future<void> definir(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, valor);
  }
}
