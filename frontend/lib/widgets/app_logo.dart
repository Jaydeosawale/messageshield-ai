import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/messageshield_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),

        if (showText) ...[
          const SizedBox(height: 8),
          const Text(
            'MessageShield AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}