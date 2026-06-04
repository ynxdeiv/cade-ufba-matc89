class NetworkException implements Exception {
  const NetworkException([this.mensagem]);
  final String? mensagem;
}

class AuthException implements Exception {
  const AuthException([this.mensagem]);
  final String? mensagem;
}

class ServerException implements Exception {
  const ServerException([this.mensagem]);
  final String? mensagem;
}

class CacheException implements Exception {
  const CacheException([this.mensagem]);
  final String? mensagem;
}

class ValidationException implements Exception {
  const ValidationException(this.campo, this.mensagem);
  final String campo;
  final String mensagem;
}
