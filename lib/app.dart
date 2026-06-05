import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'shared/theme/app_theme.dart';

final _routerProvider = Provider<GoRouter>((_) => buildRouter());

class CadeUfbaApp extends ConsumerWidget {
  const CadeUfbaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Cadê UFBA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      routerConfig: ref.watch(_routerProvider),
    );
  }
}
