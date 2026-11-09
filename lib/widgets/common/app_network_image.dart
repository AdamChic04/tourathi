import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusMedium;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: AppColors.desertGradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(
            child: Icon(Icons.landscape, color: Colors.white54, size: 32),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: AppColors.desertGradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
          ),
        ),
      ),
    );
  }
}
