import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/agenda/presentation/screens/agenda_screen.dart';
import 'features/auth/presentation/screens/auth_callback_screen.dart';
import 'features/auth/presentation/screens/bem_vindo_screen.dart';
import 'features/auth/presentation/screens/cadastro_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/recuperar_senha_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/events/presentation/screens/lista_eventos_screen.dart';
import 'features/profile/presentation/screens/perfil_screen.dart';
import 'shared/widgets/home_shell.dart';

final _rotasPublicas = {
  '/bem-vindo',
  '/login',
  '/cadastro',
  '/recuperar',
  '/auth-callback',
};

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/bem-vindo',
    refreshListenable: _SupabaseAuthListenable(),
    redirect: (context, state) {
      final logado = Supabase.instance.client.auth.currentSession != null;
      final indoParaRotaPublica = _rotasPublicas.contains(state.matchedLocation);

      if (!logado && !indoParaRotaPublica) return '/bem-vindo';
      if (logado && indoParaRotaPublica) return '/home/eventos';
      return null;
    },
    routes: [
      GoRoute(path: '/bem-vindo', builder: (_, __) => const BemVindoScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, __) => const CadastroScreen()),
      GoRoute(
        path: '/recuperar',
        builder: (_, __) => const RecuperarSenhaScreen(),
      ),
      GoRoute(
        path: '/auth-callback',
        builder: (_, __) => const AuthCallbackScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home/eventos',
            builder: (_, __) => const ListaEventosScreen(),
          ),
          GoRoute(
            path: '/home/agenda',
            builder: (_, __) => const AgendaScreen(),
          ),
          GoRoute(path: '/home/chat', builder: (_, __) => const ChatScreen()),
          GoRoute(
            path: '/home/perfil',
            builder: (_, __) => const PerfilScreen(),
          ),
        ],
      ),
      GoRoute(path: '/home', redirect: (_, __) => '/home/eventos'),
    ],
  );
}

class _SupabaseAuthListenable extends ChangeNotifier {
  _SupabaseAuthListenable() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
