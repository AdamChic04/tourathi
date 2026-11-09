import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Animated launch screen.
///
/// Starts at `/`, reveals the TouRathi compass mark and wordmark, then
/// automatically navigates to `/main` (the Home tab). No login, onboarding,
/// internet request or new dependencies are required for this demo flow.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3100),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat();

    _entrance.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_hasNavigated) {
        _hasNavigated = true;
        // Go straight to the existing home tab, not to onboarding.
        context.go('/main');
      }
    });
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  static double _progress(double t, double from, double to) {
    return ((t - from) / (to - from)).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21170F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Desert night -> sandstone gradient, consistent with TouRathi.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.53, 1.0],
                colors: [
                  Color(0xFF201810),
                  Color(0xFF523927),
                  Color(0xFF8F6440),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) => CustomPaint(
              painter: _SandAndStarsPainter(_ambient.value),
            ),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([_entrance, _ambient]),
              builder: (context, _) {
                final t = _entrance.value;
                final logoIn = _progress(t, 0.05, 0.32);
                final wordIn = _progress(t, 0.27, 0.53);
                final tagIn = _progress(t, 0.47, 0.70);
                final footIn = _progress(t, 0.64, 0.82);
                final easedLogo = Curves.easeOutBack.transform(logoIn);
                final glow = 0.65 +
                    0.35 *
                        math.sin(_ambient.value * math.pi * 2);

                // The compass is anchored at the exact horizontal/vertical center.
                // The app name animates in beneath it without moving the logo.
                return LayoutBuilder(
                  builder: (context, dimensions) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Opacity(
                          opacity: logoIn,
                          child: Transform.translate(
                            offset: Offset(0, (1 - logoIn) * 28),
                            child: Transform.scale(
                              scale: 0.60 + (0.40 * easedLogo),
                              child: SizedBox(
                                width: 190,
                                height: 190,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: (_ambient.value * math.pi * 2) / 3,
                                      child: CustomPaint(
                                        size: const Size(190, 190),
                                        painter: _CompassOrbitPainter(),
                                      ),
                                    ),
                                    Container(
                                      width: 133,
                                      height: 133,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.goldShimmer,
                                        border: Border.all(
                                          width: 1.2,
                                          color: Colors.white.withValues(alpha: 0.45),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.desertGold.withValues(
                                              alpha: 0.21 + 0.17 * glow,
                                            ),
                                            blurRadius: 25 + 17 * glow,
                                            spreadRadius: 2 + 7 * glow,
                                          ),
                                        ],
                                      ),
                                      child: Transform.rotate(
                                        angle: (1 - logoIn) * -0.38,
                                        child: const Icon(
                                          Icons.explore_rounded,
                                          size: 79,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: dimensions.maxHeight / 2 + 105,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: wordIn,
                              child: Transform.translate(
                                offset: Offset(0, (1 - wordIn) * 18),
                                child: Text(
                                  'TouRathi',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 2.6,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: tagIn,
                              child: Transform.translate(
                                offset: Offset(0, (1 - tagIn) * 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    'Discover Jordan Beyond the Ordinary',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFF3E6D4),
                                      letterSpacing: 0.3,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 38,
                        child: Opacity(
                          opacity: footIn,
                          child: Column(
                            children: [
                              Text(
                                'YOUR JOURNEY STARTS HERE',
                                style: AppTypography.poppins(
                                  color: const Color(0xFFEFD5AA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 3,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.17),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _progress(t, 0.66, 0.96),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6D898),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassOrbitPainter extends CustomPainter {
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
  bool shouldRepaint(covariant _CompassOrbitPainter oldDelegate) => false;
}

class _SandAndStarsPainter extends CustomPainter {
  _SandAndStarsPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final tau = 2 * math.pi;
    for (var i = 0; i < 36; i++) {
      final x = ((i * 37 + 11) % 101) / 101 * size.width;
      final y = ((i * 61 + 9) % 103) / 103 * size.height;
      final shimmer = 0.5 + 0.5 * math.sin(progress * tau + i * 1.7);
      final opacity = 0.06 + shimmer * 0.16;
      canvas.drawCircle(
        Offset(x, y),
        i % 7 == 0 ? 2.3 : 1.0,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }

    for (var layer = 0; layer < 3; layer++) {
      final baseY = size.height * 0.81 + layer * 32.0;
      final wave = Path()..moveTo(0, baseY);
      for (var x = 0.0; x <= size.width; x += 9) {
        final y = baseY +
            math.sin(x / 95.0 + progress * tau + layer * 0.85) *
                (10 + layer * 4);
        wave.lineTo(x, y);
      }
      wave
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        wave,
        Paint()
          ..color = const Color(0xFFE7B980).withValues(
            alpha: 0.035 + layer * 0.028,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SandAndStarsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
