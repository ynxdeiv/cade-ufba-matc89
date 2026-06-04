import 'package:flutter/material.dart';

/// Paleta do Cadê UFBA (alinhada com o mockup de auth).
class AppCores {
  const AppCores._();

  static const azulNavy = Color(0xFF0F2257);
  static const azulRoyal = Color(0xFF3D5DC3);
  static const azulCeu = Color(0xFF5BB3F0);
  static const laranja = Color(0xFFF18F2C);
  static const cinzaFundo = Color(0xFFF2F2F2);
  static const cinzaTexto = Color(0xFF6C6C6C);
  static const cinzaDivisor = Color(0xFFCFCFCF);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppCores.azulNavy,
      primary: AppCores.azulRoyal,
      secondary: AppCores.azulCeu,
      tertiary: AppCores.laranja,
      surface: AppCores.cinzaFundo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppCores.cinzaFundo,
      textTheme: const TextTheme().apply(
        bodyColor: AppCores.azulNavy,
        displayColor: AppCores.azulNavy,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        labelStyle: TextStyle(color: AppCores.azulNavy, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: AppCores.cinzaTexto),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppCores.azulRoyal, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCores.azulRoyal,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppCores.azulRoyal),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppCores.azulNavy,
          brightness: Brightness.dark,
        ),
      );
}
