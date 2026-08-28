import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Premium full-screen MessageShield background.
///
/// Layers:
/// 1. Deep navy gradient base
/// 2. Teal atmospheric glow
/// 3. Blue/teal side glow
/// 4. Green bottom glow
/// 5. Security network decoration
/// 6. Orbit decorations
/// 7. Dot pattern
/// 8. Screen content
class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        // ============================================================
        // FULL SCREEN BASE GRADIENT
        // ============================================================

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071C24),
              Color(0xFF08232B),
              Color(0xFF061920),
            ],
            stops: [
              0.0,
              0.52,
              1.0,
            ],
          ),
        ),

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ============================================================
            // TOP RIGHT TEAL ATMOSPHERIC GLOW
            // ============================================================

            Positioned(
              top: -180,
              right: -150,
              child: _Glow(
                size: 520,
                color: AppColors.teal,
                opacity: 0.14,
              ),
            ),

            // ============================================================
            // TOP LEFT SUBTLE BLUE / TEAL GLOW
            // ============================================================

            Positioned(
              top: 80,
              left: -250,
              child: _Glow(
                size: 500,
                color: AppColors.tealSoft,
                opacity: 0.045,
              ),
            ),

            // ============================================================
            // LEFT / MIDDLE TEAL GLOW
            // ============================================================

            Positioned(
              top: 280,
              left: -250,
              child: _Glow(
                size: 480,
                color: AppColors.teal,
                opacity: 0.075,
              ),
            ),

            // ============================================================
            // BOTTOM RIGHT GREEN GLOW
            // ============================================================

            Positioned(
              bottom: -260,
              right: -180,
              child: _Glow(
                size: 560,
                color: AppColors.green,
                opacity: 0.10,
              ),
            ),

            // ============================================================
            // BOTTOM LEFT SUBTLE NAVY / TEAL GLOW
            // ============================================================

            Positioned(
              bottom: -220,
              left: -200,
              child: _Glow(
                size: 450,
                color: AppColors.tealSoft,
                opacity: 0.045,
              ),
            ),

            // ============================================================
            // TOP RIGHT ORBIT
            // ============================================================

            const Positioned(
              top: 55,
              right: -30,
              child: _DecorativeOrbit(
                size: 190,
              ),
            ),

            // ============================================================
            // LEFT SECURITY NETWORK
            // ============================================================

            Positioned(
              top: 260,
              left: -55,
              child: CustomPaint(
                size: const Size(190, 190),
                painter: _NetworkPainter(),
              ),
            ),

            // ============================================================
            // RIGHT DOT PATTERN
            // ============================================================

            Positioned(
              bottom: 75,
              right: 8,
              child: CustomPaint(
                size: const Size(150, 130),
                painter: _DotPatternPainter(),
              ),
            ),

            // ============================================================
            // BOTTOM LEFT ORBIT
            // ============================================================

            const Positioned(
              bottom: -50,
              left: -50,
              child: _DecorativeOrbit(
                size: 190,
                reverse: true,
              ),
            ),

            // ============================================================
            // TOP SMALL DOT ACCENTS
            // ============================================================

            Positioned(
              top: 160,
              right: 105,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.60),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // SCREEN CONTENT
            // ============================================================

            Positioned.fill(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// SOFT ATMOSPHERIC GLOW
// ======================================================================

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Glow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.55),
              color.withValues(alpha: opacity * 0.18),
              color.withValues(alpha: 0),
            ],
            stops: const [
              0.0,
              0.35,
              0.68,
              1.0,
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// DECORATIVE ORBIT
// ======================================================================

class _DecorativeOrbit extends StatelessWidget {
  final double size;
  final bool reverse;

  const _DecorativeOrbit({
    required this.size,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _OrbitPainter(
            reverse: reverse,
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final bool reverse;

  _OrbitPainter({
    required this.reverse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width * 0.36;

    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.teal.withValues(alpha: 0.20);

    final secondaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.green.withValues(alpha: 0.15);

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final startAngle = reverse ? 0.5 : 3.5;

    canvas.drawArc(
      rect,
      startAngle,
      1.8,
      false,
      primaryPaint,
    );

    canvas.drawArc(
      rect.inflate(18),
      startAngle + 1.5,
      1.3,
      false,
      secondaryPaint,
    );

    final dotPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.48);

    canvas.drawCircle(
      Offset(
        center.dx + radius * 0.75,
        center.dy - radius * 0.55,
      ),
      3,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.85,
        center.dy + radius * 0.45,
      ),
      2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _OrbitPainter oldDelegate,
  ) {
    return oldDelegate.reverse != reverse;
  }
}

// ======================================================================
// SECURITY NETWORK VECTOR
// ======================================================================

class _NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.14)
      ..strokeWidth = 1;

    final nodePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.38);

    final nodes = <Offset>[
      Offset(size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.52, size.height * 0.08),
      Offset(size.width * 0.92, size.height * 0.32),
      Offset(size.width * 0.32, size.height * 0.54),
      Offset(size.width * 0.76, size.height * 0.72),
      Offset(size.width * 0.12, size.height * 0.90),
    ];

    void connect(int first, int second) {
      canvas.drawLine(
        nodes[first],
        nodes[second],
        linePaint,
      );
    }

    connect(0, 1);
    connect(1, 2);
    connect(0, 3);
    connect(1, 3);
    connect(2, 4);
    connect(3, 4);
    connect(3, 5);

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        2.5,
        nodePaint,
      );

      canvas.drawCircle(
        node,
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = AppColors.teal.withValues(
            alpha: 0.10,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _NetworkPainter oldDelegate,
  ) {
    return false;
  }
}

// ======================================================================
// DOT PATTERN
// ======================================================================

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 16.0;

    for (
      double x = 4;
      x < size.width;
      x += spacing
    ) {
      for (
        double y = 4;
        y < size.height;
        y += spacing
      ) {
        final fade =
            1 - (y / size.height) * 0.65;

        final paint = Paint()
          ..color = AppColors.teal.withValues(
            alpha: 0.20 * fade,
          );

        canvas.drawCircle(
          Offset(x, y),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _DotPatternPainter oldDelegate,
  ) {
    return false;
  }
}