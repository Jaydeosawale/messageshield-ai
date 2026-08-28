import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/message_analysis.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();


    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    if (auth.isAuthenticated) {
      return HomeScreen(
        onAnalysisComplete: (MessageAnalysis analysis) {
          // Callback required by HomeScreen.
          // Global refresh logic can be added here later.
        },
      );
    }


    return const LoginScreen();
  }
}

