import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cade_ufba/features/auth/presentation/screens/login_screen.dart';
import 'package:cade_ufba/shared/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen renderiza com tema do app', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Esqueci minha senha'), findsOneWidget);
  });
}
