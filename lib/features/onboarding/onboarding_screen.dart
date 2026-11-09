import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      titleKey: 'onboarding1Title',
      descKey: 'onboarding1Desc',
      icon: Icons.auto_awesome,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B6FD4), Color(0xFF5B8DEF), Color(0xFFC89B3C)],
      ),
      accentColor: Color(0xFF3B6FD4),
    ),
    _OnboardingPageData(
      titleKey: 'onboarding2Title',
      descKey: 'onboarding2Desc',
      icon: Icons.view_in_ar,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A5C3E), Color(0xFFC89B3C), Color(0xFFD9C2A3)],
      ),
      accentColor: AppColors.desertGold,
    ),
    _OnboardingPageData(
      titleKey: 'onboarding3Title',
      descKey: 'onboarding3Desc',
      icon: Icons.groups_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E8B6E), Color(0xFF4CAF88), Color(0xFF7A5C3E)],
      ),
      accentColor: AppColors.emerald,
    ),
    _OnboardingPageData(
      titleKey: 'onboarding4Title',
      descKey: 'onboarding4Desc',
      icon: Icons.emoji_events_rounded,
      gradient: AppColors.desertGradient,
      accentColor: AppColors.warmBrown,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _nextPage(bool isArabic) {
    if (_isLastPage) {
      context.read<AppProvider>().completeOnboarding();
      context.go('/main');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skip() {
    context.read<AppProvider>().completeOnboarding();
    context.go('/main');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                isArabic: isArabic,
                pageIndex: index,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isLastPage)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        AppStrings.get('skip', isArabic),
                        style: AppTypography.textStyle(
                          isArabic: isArabic,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warmBrown,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                      activeDotColor: AppColors.desertGold,
                      dotColor: AppColors.sandBeige.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: GradientButton(
              label: _isLastPage
                  ? AppStrings.get('getStarted', isArabic)
                  : AppStrings.get('next', isArabic),
              icon: _isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              onPressed: () => _nextPage(isArabic),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });

  final String titleKey;
  final String descKey;
  final IconData icon;
  final Gradient gradient;
  final Color accentColor;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.isArabic,
    required this.pageIndex,
  });

  final _OnboardingPageData data;
  final bool isArabic;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.ivoryWhite,
            data.accentColor.withValues(alpha: 0.08),
            AppColors.sandBeige.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 120),
          child: Column(
            children: [
              Expanded(
                child: _Illustration(
                  gradient: data.gradient,
                  icon: data.icon,
                  pageIndex: pageIndex,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.get(data.titleKey, isArabic),
                style: AppTypography.textStyle(
                  isArabic: isArabic,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                AppStrings.get(data.descKey, isArabic),
                style: AppTypography.textStyle(
                  isArabic: isArabic,
                  fontSize: 16,
                  color: AppColors.warmBrown,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideY(begin: 0.15, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.gradient,
    required this.icon,
    required this.pageIndex,
  });

  final Gradient gradient;
  final IconData icon;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.desertGold.withValues(alpha: 0.25),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 700.ms,
              curve: Curves.easeOutBack,
            ),
        ...List.generate(3, (i) {
          return Positioned(
            top: 30 + i * 70.0,
            left: i.isEven ? 20.0 : null,
            right: i.isOdd ? 20.0 : null,
            child: Container(
              width: 48 + i * 12.0,
              height: 48 + i * 12.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -6,
                  end: 6,
                  duration: (2 + i).seconds,
                  curve: Curves.easeInOut,
                )
                .fadeIn(delay: (200 * i).ms),
          );
        }),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 56, color: Colors.white),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
      ],
    );
  }
}
