import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';

class ArHubScreen extends StatefulWidget {
  const ArHubScreen({super.key});

  @override
  State<ArHubScreen> createState() => _ArHubScreenState();
}

class _ArHubScreenState extends State<ArHubScreen>
    with SingleTickerProviderStateMixin {
  int _selectedSiteIndex = 0;
  bool _isScanning = true;
  bool _narrationOn = true;
  double _zoomLevel = 1.0;
  double _rotation = 0;

  static const _sites = [
    _ArSite(
      id: 'petra',
      name: 'Petra',
      nameAr: 'البتراء',
      subtitle: 'The Rose City',
      imageUrl:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=800',
    ),
    _ArSite(
      id: 'jerash',
      name: 'Jerash',
      nameAr: 'جرش',
      subtitle: 'Roman Decapolis',
      imageUrl:
          'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=800',
    ),
    _ArSite(
      id: 'amman-citadel',
      name: 'Amman Citadel',
      nameAr: 'قلعة عمان',
      subtitle: 'Ancient Rabbath Ammon',
      imageUrl:
          'https://images.unsplash.com/photo-1586724676337-5a1a8b8e8e8e?w=800',
    ),
  ];

  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final site = _sites[_selectedSiteIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(AppStrings.get('arHub', isArabic)),
        actions: [
          IconButton(
            icon: Icon(
              _isScanning ? Icons.pause_circle_outline : Icons.play_circle_outline,
            ),
            onPressed: () => setState(() => _isScanning = !_isScanning),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.rotate(
            angle: _rotation * math.pi / 180,
            child: Transform.scale(
              scale: _zoomLevel,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: site.imageUrl,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanGridPainter(_scanController.value),
                  size: Size.infinite,
                );
              },
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 70,
            left: 20,
            right: 20,
            child: _HudPanel(
              site: site,
              isArabic: isArabic,
              isScanning: _isScanning,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 220,
            child: Center(
              child: _ScanIndicator(active: _isScanning),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _sites.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final s = _sites[index];
                          final selected = index == _selectedSiteIndex;
                          return _SiteSelectorCard(
                            site: s,
                            isArabic: isArabic,
                            selected: selected,
                            onTap: () => setState(() {
                              _selectedSiteIndex = index;
                              _isScanning = true;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ArControlButton(
                            icon: Icons.rotate_right_rounded,
                            label: isArabic ? 'دوران' : 'Rotate',
                            onTap: () => setState(() => _rotation += 15),
                          ),
                          _ArControlButton(
                            icon: Icons.zoom_in_rounded,
                            label: isArabic ? 'تكبير' : 'Zoom',
                            onTap: () => setState(
                              () => _zoomLevel = (_zoomLevel + 0.1).clamp(0.8, 1.5),
                            ),
                          ),
                          _ArControlButton(
                            icon: Icons.info_outline_rounded,
                            label: isArabic ? 'معلومات' : 'Info',
                            onTap: () {},
                          ),
                          _ArControlButton(
                            icon: _narrationOn
                                ? Icons.record_voice_over_rounded
                                : Icons.voice_over_off_rounded,
                            label: isArabic ? 'سرد' : 'Narrate',
                            active: _narrationOn,
                            onTap: () =>
                                setState(() => _narrationOn = !_narrationOn),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArSite {
  const _ArSite({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.subtitle,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String nameAr;
  final String subtitle;
  final String imageUrl;
}

class _HudPanel extends StatelessWidget {
  const _HudPanel({
    required this.site,
    required this.isArabic,
    required this.isScanning,
  });

  final _ArSite site;
  final bool isArabic;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppTheme.radiusMedium,
      gradient: LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.6),
          Colors.black.withValues(alpha: 0.35),
        ],
      ),
      border: Border.all(color: AppColors.desertGold.withValues(alpha: 0.4)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.desertGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.view_in_ar_rounded,
                color: AppColors.desertGold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? site.nameAr : site.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  site.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isScanning
                  ? AppColors.emerald.withValues(alpha: 0.25)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isScanning ? AppColors.emerald : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isScanning ? AppColors.emerald : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isScanning
                      ? (isArabic ? 'مسح' : 'Scanning')
                      : (isArabic ? 'متوقف' : 'Paused'),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ScanIndicator extends StatelessWidget {
  const _ScanIndicator({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.desertGold.withValues(alpha: 0.6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 1500.ms,
              ),
          const Icon(Icons.crop_free_rounded,
              color: AppColors.desertGold, size: 32),
        ],
      ),
    );
  }
}

class _SiteSelectorCard extends StatelessWidget {
  const _SiteSelectorCard({
    required this.site,
    required this.isArabic,
    required this.selected,
    required this.onTap,
  });

  final _ArSite site;
  final bool isArabic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: selected ? AppColors.desertGold : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(imageUrl: site.imageUrl, borderRadius: 0),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                isArabic ? site.nameAr : site.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArControlButton extends StatelessWidget {
  const _ArControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.desertGold.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.desertGold : Colors.white24,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  _ScanGridPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.desertGold.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final scanY = size.height * progress;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.desertGold.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 60));
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 2, size.width, 4),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
