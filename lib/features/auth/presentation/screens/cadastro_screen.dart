import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/usecases/validadores.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_email.dart';
import '../widgets/campo_senha.dart';
import '../widgets/header_ondas.dart';
import '../widgets/painel_form.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_senha.text != _confirma.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem')),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).cadastrar(
          nome: _nome.text,
          email: _email.text,
          senha: _senha.text,
        );
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

    if (state case Cadastrado()) {
      return _ConfirmacaoEmailScreen(email: _email.text);
    }

    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderOndas(altura: 240),
              PainelForm(
                titulo: 'Criar conta',
                children: [
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nome,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            hintText: 'Como devemos te chamar',
                          ),
                          validator: (v) =>
                              Validadores.mensagemNome(v ?? ''),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CampoEmail(controller: _email),
                        const SizedBox(height: 16),
                        CampoSenha(
                          controller: _senha,
                          label: 'Senha',
                          hint: 'Mínimo 8 caracteres, 1 letra e 1 número',
                          validarForca: true,
                        ),
                        const SizedBox(height: 16),
                        CampoSenha(
                          controller: _confirma,
                          label: 'Confirmar senha',
                          hint: 'Repita a senha',
                        ),
                        const SizedBox(height: 24),
                        BotaoPrimario(
                          texto: 'Criar conta',
                          carregando: carregando,
                          onPressed: _enviar,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Já tenho conta'),
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

class _ConfirmacaoEmailScreen extends StatelessWidget {
  const _ConfirmacaoEmailScreen({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppCores.azulRoyal,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verifique seu email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppCores.azulNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um link de confirmação para $email. '
                'Abra esse link no seu celular para ativar sua conta.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppCores.cinzaTexto),
              ),
              const SizedBox(height: 32),
              BotaoPrimario(
                texto: 'Voltar para login',
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
