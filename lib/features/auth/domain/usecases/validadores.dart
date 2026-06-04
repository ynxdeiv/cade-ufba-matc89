/// Validadores compartilhados entre use cases e widgets de formulário.
class Validadores {
  const Validadores._();

  /// Regex pragmática (não-RFC) suficiente para feedback em UI.
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Mínimo: 8 caracteres, pelo menos 1 letra e 1 dígito.
  static final RegExp _senhaForte = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

  static bool emailValido(String email) => _email.hasMatch(email.trim());

  static bool senhaForte(String senha) => _senhaForte.hasMatch(senha);

  static String? mensagemEmail(String email) {
    final v = email.trim();
    if (v.isEmpty) return 'Informe seu e-mail';
    if (!emailValido(v)) return 'E-mail inválido';
    return null;
  }

  static String? mensagemSenha(String senha) {
    if (senha.isEmpty) return 'Informe uma senha';
    if (senha.length < 8) return 'Use pelo menos 8 caracteres';
    if (!senhaForte(senha)) {
      return 'A senha precisa ter ao menos 1 letra e 1 número';
    }
    return null;
  }

  static String? mensagemNome(String nome) {
    final v = nome.trim();
    if (v.isEmpty) return 'Informe seu nome';
    if (v.length < 2) return 'Nome muito curto';
    return null;
  }
}
