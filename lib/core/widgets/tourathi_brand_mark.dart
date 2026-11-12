import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The existing TouRathi splash-screen branding, shared without creating
/// or substituting a new image logo.
class TouRathiCompassMark extends StatelessWidget {
  const TouRathiCompassMark({
    super.key,
    this.size = 190,
    this.orbitAngle = 0,
    this.iconAngle = 0,
    this.glow = 0.8,
    this.showGlow = true,
  });

  final double size;
  final double orbitAngle;
  final double iconAngle;
  final double glow;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: orbitAngle,
            child: CustomPaint(
              size: Size(size, size),
              painter: const TouRathiCompassOrbitPainter(),
            ),
          ),
          Container(
            width: size * (133 / 190),
            height: size * (133 / 190),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldShimmer,
              border: Border.all(
                width: 1.2 * size / 190,
                color: Colors.white.withValues(alpha: 0.45),
              ),
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: AppColors.desertGold.withValues(
                          alpha: 0.21 + 0.17 * glow,
                        ),
                        blurRadius: (25 + 17 * glow) * size / 190,
                        spreadRadius: (2 + 7 * glow) * size / 190,
                      ),
                    ]
                  : null,
            ),
            child: Transform.rotate(
              angle: iconAngle,
              child: Icon(
                Icons.explore_rounded,
                size: size * (79 / 190),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static, non-interactive, app-wide watermark using the SAME TouRathi mark
/// and wordmark as the animated splash. This overlays the current route at
/// very low opacity because existing screens use opaque Scaffold backgrounds.
class TouRathiBrandWatermark extends StatelessWidget {
  const TouRathiBrandWatermark({
    super.key,
    this.opacity = 0.09,
  });

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      key: const Key('tourathi_watermark_ignores_taps'),
      child: ExcludeSemantics(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.84,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Opacity(
                opacity: opacity,
                child: SizedBox(
                  width: 330,
                  height: 365,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TouRathiCompassMark(
                        key: Key('tourathi_watermark_compass'),
                        size: 206,
                        showGlow: false,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'TouRathi',
                        key: const Key('tourathi_watermark_wordmark'),
                        style: AppTypography.poppins(
                          fontSize: 41,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.6,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF583B22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Exact orbit/ring geometry moved from SplashScreen so that the splash and
/// the watermark render one consistent brand mark.
class TouRathiCompassOrbitPainter extends CustomPainter {
  const TouRathiCompassOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final ring = Paint()
      ..color = const Color(0xFFE9D0AA).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(center, radius, ring);

    final arc = Paint()
      ..color = const Color(0xFFFFE4B5).withValues(alpha: 0.94)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 3,
      math.pi / 3,
      false,
      arc,
    );

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        i == 0 ? 4 : 2.2,
        Paint()..color = const Color(0xFFF9DFA8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TouRathiCompassOrbitPainter oldDelegate) => false;
}
