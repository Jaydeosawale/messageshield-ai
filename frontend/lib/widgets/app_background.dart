import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Quiet background keeps message content and risk indicators prominent.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.backgroundSoft],
          )),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      );
}
