import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:messageshield/l10n/app_localizations.dart';
import 'package:messageshield/providers/auth_provider.dart';
import 'package:messageshield/core/theme/app_theme.dart';
import 'package:messageshield/screens/auth/login_screen.dart';
import 'package:messageshield/screens/auth/register_screen.dart';
import 'package:messageshield/screens/auth/forgot_password_page.dart';
import 'package:messageshield/main.dart' as app;

class ReadyAuth extends AuthProvider {
  @override
  bool get isInitialized => true;
}

void main() {
  testWidgets('authentication pages fit supported locales and screen sizes',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final locale in AppLocalizations.supportedLocales) {
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(1440, 900)
      ]) {
        tester.view.physicalSize = size;
        for (final page in [
          const LoginScreen(),
          const RegisterScreen(),
          const ForgotPasswordPage(),
          const app.AuthGate()
        ]) {
          await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
              create: (_) => ReadyAuth(),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: page,
              )));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '$page at $size in $locale');
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  });
}
