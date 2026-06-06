import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/atualizar_perfil.dart';
import '../../domain/usecases/obter_perfil.dart';

final _remoteProvider = Provider<ProfileRemoteDatasource>(
  (_) => ProfileRemoteDatasource(sb.Supabase.instance.client),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(_remoteProvider)),
);

final _obterProvider = Provider<ObterPerfil>(
  (ref) => ObterPerfil(ref.watch(profileRepositoryProvider)),
);

final _atualizarProvider = Provider<AtualizarPerfil>(
  (ref) => AtualizarPerfil(ref.watch(profileRepositoryProvider)),
);

sealed class ProfileState {
  const ProfileState();
}

class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

class ProfileCarregando extends ProfileState {
  const ProfileCarregando();
}

class ProfileCarregado extends ProfileState {
  const ProfileCarregado(this.perfil, {this.salvando = false, this.sucesso = false});
  final Perfil perfil;
  final bool salvando;
  final bool sucesso;

  ProfileCarregado copyWith({Perfil? perfil, bool? salvando, bool? sucesso}) =>
      ProfileCarregado(
        perfil ?? this.perfil,
        salvando: salvando ?? this.salvando,
        sucesso: sucesso ?? this.sucesso,
      );
}

class ProfileErro extends ProfileState {
  const ProfileErro(this.failure, {this.perfilAnterior});
  final Failure failure;
  final Perfil? perfilAnterior;
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({
    required ObterPerfil obter,
    required AtualizarPerfil atualizar,
    required this.ref,
  })  : _obter = obter,
        _atualizar = atualizar,
        super(const ProfileIdle());

  final ObterPerfil _obter;
  final AtualizarPerfil _atualizar;
  final Ref ref;

  Future<void> carregar() async {
    state = const ProfileCarregando();
    final r = await _obter(const NoParams());
    state = r.fold(
      (f) => ProfileErro(f),
      (p) => ProfileCarregado(p),
    );
  }

  Future<bool> salvar(Perfil novo) async {
    final atual = state;
    final anterior = atual is ProfileCarregado ? atual.perfil : null;
    state = atual is ProfileCarregado
        ? atual.copyWith(salvando: true, sucesso: false)
        : ProfileCarregado(novo, salvando: true);

    final r = await _atualizar(novo);
    return r.fold(
      (f) {
        state = ProfileErro(f, perfilAnterior: anterior);
        return false;
      },
      (p) {
        state = ProfileCarregado(p, salvando: false, sucesso: true);
        _sincronizarAuth(p);
        return true;
      },
    );
  }

  void _sincronizarAuth(Perfil p) {
    final auth = ref.read(authControllerProvider);
    if (auth is! Autenticado) return;
    final atualizado = Usuario(
      id: auth.usuario.id,
      email: auth.usuario.email,
      nome: p.nome,
      vinculo: p.vinculo?.valor,
      cursoDepartamento: p.cursoDepartamento,
      fotoUrl: p.fotoUrl,
    );
    ref.read(authControllerProvider.notifier).atualizarUsuario(atualizado);
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(
    obter: ref.watch(_obterProvider),
    atualizar: ref.watch(_atualizarProvider),
    ref: ref,
  ),
);
