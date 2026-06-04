import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure([this.mensagem]);

  final String? mensagem;

  @override
  List<Object?> get props => [mensagem];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.mensagem]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.mensagem]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.mensagem]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.mensagem]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.campo, String mensagem) : super(mensagem);

  final String campo;

  @override
  List<Object?> get props => [campo, mensagem];
}
