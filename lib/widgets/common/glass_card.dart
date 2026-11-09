import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.onTap,
    this.gradient,
    this.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppTheme.radiusMedium;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: gradient ??
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppColors.darkCard.withValues(alpha: 0.8),
                              AppColors.darkSurface.withValues(alpha: 0.6),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.85),
                              AppColors.ivoryWhite.withValues(alpha: 0.7),
                            ],
                    ),
                borderRadius: BorderRadius.circular(radius),
                border: border ??
                    Border.all(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.5)
                          : AppColors.sandBeige.withValues(alpha: 0.4),
                    ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warmBrown.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
