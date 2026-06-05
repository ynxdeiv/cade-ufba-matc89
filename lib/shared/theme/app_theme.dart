import 'package:flutter/material.dart';

/// Sistema de cores do Cadê UFBA.
///
/// Escala derivada de auditoria WCAG sobre o tema inicial:
///   - tons distribuídos em degraus 50/100/300/500/700/900 para
///     conseguir hierarquia visual sem cair em "preto" para texto;
///   - neutros com leve viés azul ("azul-tinta") em vez de cinza
///     frio, mantendo coerência com a brand;
///   - todas as combinações de texto sobre fundo neutro passam ao
///     menos em AA (>= 4.5) — a maioria em AAA (>= 7).
///
/// Aliases (`azulNavy`, `azulRoyal`, `azulCeu`, `cinzaFundo`,
/// `cinzaTexto`, `cinzaDivisor`, `laranja`) são mantidos para
/// compatibilidade com telas já entregues (FE-002).
class AppCores {
  const AppCores._();

  // ------------------------------------------------------------------
  // Brand — escala de azul
  // ------------------------------------------------------------------
  static const azul50 = Color(0xFFEAF2FC);
  static const azul100 = Color(0xFFC9DEF7);
  static const azul300 = Color(0xFF5896E5);
  static const azul500 = Color(0xFF1F5FCC); // primário
  static const azul700 = Color(0xFF143E8C);
  static const azul900 = Color(0xFF0E2A66); // AppBar / headers escuros

  // ------------------------------------------------------------------
  // Neutros (azul-tinta — não cinza puro)
  // ------------------------------------------------------------------
  static const neutro900 = Color(0xFF1A2333); // texto principal
  static const neutro700 = Color(0xFF4A5468); // texto secundário, ícones
  static const neutro500 = Color(0xFF7D8694); // captions, hints
  static const neutro300 = Color(0xFFC9CED6); // divisores, bordas em repouso
  static const neutro100 = Color(0xFFEEF1F5); // fundo de tela
  static const neutro0 = Color(0xFFFFFFFF); // superfície de cartão

  // ------------------------------------------------------------------
  // Accent — destaques pontuais
  // ------------------------------------------------------------------
  static const laranja600 = Color(0xFFD97706);
  static const verde600 = Color(0xFF0F8E5E);
  static const vermelho600 = Color(0xFFC8324A);

  // ------------------------------------------------------------------
  // Aliases (compatibilidade com FE-002 já entregue)
  // ------------------------------------------------------------------
  static const azulNavy = azul900;
  static const azulRoyal = azul500;
  static const azulCeu = azul300;
  static const laranja = laranja600;
  static const cinzaFundo = neutro100;
  static const cinzaTexto = neutro700;
  static const cinzaDivisor = neutro300;
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppCores.azul500,
      primary: AppCores.azul500,
      onPrimary: Colors.white,
      secondary: AppCores.azul300,
      tertiary: AppCores.laranja600,
      surface: AppCores.neutro0,
      onSurface: AppCores.neutro900,
      error: AppCores.vermelho600,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppCores.neutro100,
      textTheme: const TextTheme().apply(
        bodyColor: AppCores.neutro900,
        displayColor: AppCores.neutro900,
      ),
      cardTheme: CardThemeData(
        color: AppCores.neutro0,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: AppCores.neutro300),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppCores.neutro300),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppCores.neutro300),
        ),
        labelStyle: TextStyle(
          color: AppCores.neutro900,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: AppCores.neutro500),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppCores.azul500, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCores.azul500,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppCores.azul500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppCores.neutro0,
        selectedColor: AppCores.azul500,
        labelStyle: const TextStyle(
          color: AppCores.neutro900,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppCores.neutro300),
        shape: const StadiumBorder(),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppCores.azul500,
          brightness: Brightness.dark,
        ),
      );
}
