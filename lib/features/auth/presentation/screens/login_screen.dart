import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tela de login (placeholder)'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/cadastro'),
              child: const Text('Criar conta'),
            ),
            TextButton(
              onPressed: () => context.go('/recuperar'),
              child: const Text('Esqueci minha senha'),
            ),
          ],
        ),
      ),
    );
  }
}
