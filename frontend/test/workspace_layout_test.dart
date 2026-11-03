import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:messageshield/core/theme/app_theme.dart';
import 'package:messageshield/l10n/app_localizations.dart';
import 'package:messageshield/models/message_analysis.dart';
import 'package:messageshield/models/user.dart';
import 'package:messageshield/providers/auth_provider.dart';
import 'package:messageshield/providers/language_provider.dart';
import 'package:messageshield/screens/home/home_screen.dart';
import 'package:messageshield/screens/dashboard/dashboard_screen.dart';
import 'package:messageshield/screens/history/history_screen.dart';
import 'package:messageshield/screens/history/analysis_detail_screen.dart';
import 'package:messageshield/screens/profile/profile_screen.dart';

class WorkspaceAuth extends AuthProvider {
  @override
  User get user => const User(
      id: 1,
      email: 'preview@example.test',
      isActive: true,
      isAdmin: false,
      emailVerified: true,
      authProvider: 'password');
  @override
  firebase.User? get firebaseUser => null;
}

void main() {
  testWidgets(
      'workspace screens fit all supported locales in the shared light theme',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test-only'});
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    final data = {
      'id': 1,
      'safe_message': 'Your account will be blocked. Share your OTP now.',
      'category': 'PHISHING',
      'confidence': 0.94,
      'risk': 'HIGH',
      'risk_score': 90,
      'signals': [],
      'probabilities': {'PHISHING': 0.94, 'SAFE': 0.06},
      'model': {'name': 'test', 'version': '1'},
      'created_at': '2026-11-03T09:00:00Z'
    };
    final errors = <String>[];
    await http.runWithClient(() async {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final size in [
          const Size(320, 640),
          const Size(390, 844),
          const Size(1440, 900)
        ]) {
          tester.view.physicalSize = size;
          for (final page in [
            HomeScreen(onAnalysisComplete: (_) {}),
            const SafetyGuidelinesScreen(),
            const DashboardScreen(),
            const HistoryScreen(),
            const ProfileScreen(),
            AnalysisDetailScreen(analysis: MessageAnalysis.fromJson(data))
          ]) {
            await tester.pumpWidget(MultiProvider(
                providers: [
                  ChangeNotifierProvider<AuthProvider>(
                      create: (_) => WorkspaceAuth()),
                  ChangeNotifierProvider(create: (_) => LanguageProvider()),
                ],
                child: MaterialApp(
                    theme: AppTheme.lightTheme,
                    locale: locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: Scaffold(body: page))));
            await tester.pumpAndSettle();
            final error = tester.takeException();
            if (error != null) {
              errors.add('$page at $size in $locale: $error');
            }
            await tester.pumpWidget(const SizedBox());
          }
        }
      }
    },
        () => MockClient((_) async => http.Response(
            jsonEncode({
              'items': [data],
              'total': 1,
              'skip': 0,
              'limit': 20
            }),
            200)));
    expect(errors, isEmpty);
  });
}
