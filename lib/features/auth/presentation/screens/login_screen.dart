import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_email.dart';
import '../widgets/campo_senha.dart';
import '../widgets/header_ondas.dart';
import '../widgets/painel_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _manterConectado = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).entrar(
          email: _email.text,
          senha: _senha.text,
          manterConectado: _manterConectado,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // Após autenticação, navega para a home.
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      switch (next) {
        case Autenticado():
          context.go('/home/eventos');
        case Erro(:final mensagem):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensagem)),
          );
        default:
          break;
      }
    });

    final erroAuth = switch (state) {
      Erro(:final mensagem) => mensagem,
      _ => null,
    };
    final carregando = state is Loading;

    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderOndas(altura: 280),
              PainelForm(
                titulo: 'Login',
                children: [
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CampoEmail(controller: _email),
                        const SizedBox(height: 16),
                        CampoSenha(controller: _senha),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _manterConectado,
                              onChanged: (v) => setState(
                                () => _manterConectado = v ?? false,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Lembre de mim'),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.go('/recuperar'),
                              child: const Text('Esqueceu a senha?'),
                            ),
                          ],
                        ),
                        if (erroAuth != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            erroAuth,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        BotaoPrimario(
                          texto: 'Avançar',
                          onPressed: _enviar,
                          carregando: carregando,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/cadastro'),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: AppCores.azulNavy,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: 'Não tem conta? Faça seu '),
                                  TextSpan(
                                    text: 'cadastro',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' aqui'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
