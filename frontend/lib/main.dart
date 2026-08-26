import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/auth_gate.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..initialize(),
      child: const MessageShieldApp(),
    ),
  );
}

class MessageShieldApp extends StatelessWidget {
  const MessageShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF08111F);
    const surfaceColor = Color(0xFF101C2E);
    const primaryColor = Color(0xFF4F8CFF);
    const secondaryColor = Color(0xFF00B8D9);

    return MaterialApp(
      title: 'MessageShield',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: backgroundColor,

        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          error: Color(0xFFFF5C70),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: Color(0xFF20314D),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0C1728),

          contentPadding: const EdgeInsets.all(18),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2A3C59),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2A3C59),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFFF5C70),
            ),
          ),

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,

            minimumSize: const Size(
              double.infinity,
              54,
            ),

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF18263D),
          contentTextStyle: const TextStyle(
            color: Colors.white,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}