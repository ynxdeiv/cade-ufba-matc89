import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/manter_conectado_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/cadastrar.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/recuperar_senha.dart';
import 'auth_state.dart';

final _datasourceProvider = Provider<AuthRemoteDatasource>(
  (_) => AuthRemoteDatasource(sb.Supabase.instance.client),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_datasourceProvider)),
);

final _loginProvider = Provider((ref) => Login(ref.watch(authRepositoryProvider)));
final _cadastrarProvider =
    Provider((ref) => Cadastrar(ref.watch(authRepositoryProvider)));
final _recuperarSenhaProvider =
    Provider((ref) => RecuperarSenha(ref.watch(authRepositoryProvider)));
final _logoutProvider = Provider((ref) => Logout(ref.watch(authRepositoryProvider)));

final manterConectadoServiceProvider =
    Provider<ManterConectadoService>((_) => ManterConectadoService());

/// Stream da sessão atual — usado pelo router e por widgets que
/// reagem a login/logout.
final sessaoAtualProvider = StreamProvider<Usuario?>(
  (ref) => ref.watch(authRepositoryProvider).sessionStream(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required Login login,
    required Cadastrar cadastrar,
    required RecuperarSenha recuperarSenha,
    required Logout logout,
    required ManterConectadoService manterConectado,
  })  : _login = login,
        _cadastrar = cadastrar,
        _recuperarSenha = recuperarSenha,
        _logout = logout,
        _manterConectado = manterConectado,
        super(const AuthState.idle());

  final Login _login;
  final Cadastrar _cadastrar;
  final RecuperarSenha _recuperarSenha;
  final Logout _logout;
  final ManterConectadoService _manterConectado;

  Future<void> entrar({
    required String email,
    required String senha,
    required bool manterConectado,
  }) async {
    state = const AuthState.loading();
    final r = await _login(ParametrosLogin(email: email, senha: senha));
    state = await r.fold(
      (f) async => AuthState.erro(_msgFalha(f), campo: _campoFalha(f)),
      (u) async {
        await _manterConectado.definir(manterConectado);
        return AuthState.autenticado(u);
      },
    );
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state = const AuthState.loading();
    final r = await _cadastrar(ParametrosCadastro(
      nome: nome,
      email: email,
      senha: senha,
    ));
    state = r.fold(
      (f) => AuthState.erro(_msgFalha(f), campo: _campoFalha(f)),
      (_) => const AuthState.cadastrado(),
    );
  }

  Future<void> esqueciSenha(String email) async {
    state = const AuthState.loading();
    final r = await _recuperarSenha(email);
    state = r.fold(
      (f) => AuthState.erro(_msgFalha(f), campo: _campoFalha(f)),
      (_) => const AuthState.emailEnviado(),
    );
  }

  Future<void> sair() async {
    state = const AuthState.loading();
    await _logout(const NoParams());
    await _manterConectado.definir(false);
    state = const AuthState.idle();
  }

  void limpar() => state = const AuthState.idle();

  /// Substitui o usuário do estado atual quando outra feature (perfil)
  /// edita os dados, para que o restante do app reflita as alterações
  /// sem precisar de novo login.
  void atualizarUsuario(Usuario novo) {
    if (state is Autenticado) {
      state = AuthState.autenticado(novo);
    }
  }

  String _msgFalha(Failure f) {
    if (f is ValidationFailure) return f.mensagem ?? 'Campo inválido';
    if (f is AuthFailure) return f.mensagem ?? 'Email ou senha inválidos';
    if (f is NetworkFailure) {
      return f.mensagem ?? 'Sem conexão. Tente novamente.';
    }
    return f.mensagem ?? 'Algo deu errado. Tente novamente.';
  }

  String? _campoFalha(Failure f) => f is ValidationFailure ? f.campo : null;
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    login: ref.watch(_loginProvider),
    cadastrar: ref.watch(_cadastrarProvider),
    recuperarSenha: ref.watch(_recuperarSenhaProvider),
    logout: ref.watch(_logoutProvider),
    manterConectado: ref.watch(manterConectadoServiceProvider),
  ),
);
