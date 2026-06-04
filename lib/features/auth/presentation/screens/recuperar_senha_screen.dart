import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_email.dart';
import '../widgets/header_ondas.dart';
import '../widgets/painel_form.dart';

class RecuperarSenhaScreen extends ConsumerStatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  ConsumerState<RecuperarSenhaScreen> createState() =>
      _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends ConsumerState<RecuperarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).esqueciSenha(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final carregando = state is Loading;

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next case Erro(:final mensagem)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderOndas(altura: 240),
              PainelForm(
                titulo: 'Recuperar senha',
                children: [
                  if (state case EmailEnviado())
                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 72,
                          color: AppCores.azulRoyal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enviamos um link para ${_email.text}. '
                          'Verifique sua caixa de entrada.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppCores.cinzaTexto),
                        ),
                        const SizedBox(height: 24),
                        BotaoPrimario(
                          texto: 'Voltar',
                          onPressed: () => context.go('/login'),
                        ),
                      ],
                    )
                  else
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Digite o email da sua conta para receber um link '
                            'de redefinição de senha.',
                            style: TextStyle(color: AppCores.cinzaTexto),
                          ),
                          const SizedBox(height: 16),
                          CampoEmail(controller: _email),
                          const SizedBox(height: 24),
                          BotaoPrimario(
                            texto: 'Avançar',
                            carregando: carregando,
                            onPressed: _enviar,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Voltar para login'),
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
