import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Tela alcançada via deep link `cadeufba://auth-callback` após o
/// usuário clicar no link de confirmação/recuperação de email. Aguarda
/// o supabase processar o token e redireciona conforme o estado.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    // Fallback: se em 8s nada chegar, voltamos para login.
    _timeout = Timer(const Duration(seconds: 8), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessaoAtualProvider, (_, next) {
      next.whenData((usuario) {
        if (usuario != null && mounted) {
          _timeout?.cancel();
          context.go('/home/eventos');
        }
      });
    });

    return const Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
