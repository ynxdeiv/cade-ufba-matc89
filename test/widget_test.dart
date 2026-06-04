import 'package:cade_ufba/features/auth/presentation/screens/bem_vindo_screen.dart';
import 'package:cade_ufba/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('BemVindoScreen renderiza título e CTA', (tester) async {
    final router = GoRouter(
      initialLocation: '/bem-vindo',
      routes: [
        GoRoute(path: '/bem-vindo', builder: (_, __) => const BemVindoScreen()),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(body: SizedBox()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ));

    expect(find.text('BEM-VINDO'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(
      find.textContaining('Conectando você aos eventos da UFBA'),
      findsOneWidget,
    );
  });
}
