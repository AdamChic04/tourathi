import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/ai_glow_card.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';

class AiImageGeneratorScreen extends StatefulWidget {
  const AiImageGeneratorScreen({super.key});

  @override
  State<AiImageGeneratorScreen> createState() => _AiImageGeneratorScreenState();
}

class _AiImageGeneratorScreenState extends State<AiImageGeneratorScreen> {
  AiTemplate? _selectedTemplate;
  bool _hasUpload = false;
  bool _isGenerating = false;
  bool _hasResult = false;
  double _sliderPosition = 0.5;

  static const _sampleBefore =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800';
  static const _sampleAfter =
      'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800';

  Future<void> _generate() async {
    if (_selectedTemplate == null || !_hasUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().isArabic
                ? 'يرجى رفع صورة واختيار قالب'
                : 'Please upload a photo and select a template',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasResult = false;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _hasResult = true;
      _sliderPosition = 0.5;
    });
  }

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final templates = MockData.aiTemplates;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.get('aiImageGen', isArabic)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.aiGlow),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.history_edu_rounded,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                isArabic
                    ? 'حوّل صورتك إلى شخصية تاريخية أردنية'
                    : 'Transform your photo into a Jordanian historical character',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmBrown,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _UploadArea(
                hasUpload: _hasUpload,
                isArabic: isArabic,
                onTap: () => setState(() => _hasUpload = true),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: isArabic ? 'اختر الشخصية' : 'Choose Character',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final selected = _selectedTemplate?.id == template.id;
                  return _TemplateCard(
                    template: template,
                    isArabic: isArabic,
                    selected: selected,
                    onTap: () => setState(() => _selectedTemplate = template),
                  );
                },
              ),
            ),
          ),
          if (_selectedTemplate != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.royalBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTemplate!.prompt,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                label: AppStrings.get('generate', isArabic),
                icon: Icons.auto_fix_high_rounded,
                gradient: AppColors.aiGlow,
                isLoading: _isGenerating,
                onPressed: _isGenerating ? null : _generate,
                width: double.infinity,
              ),
            ),
          ),
          if (_hasResult) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: isArabic ? 'قبل / بعد' : 'Before / After',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BeforeAfterSlider(
                  beforeUrl: _sampleBefore,
                  afterUrl: _selectedTemplate?.imageUrl ?? _sampleAfter,
                  sliderPosition: _sliderPosition,
                  onSlide: (value) => setState(() => _sliderPosition = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        icon: Icons.download_rounded,
                        label: AppStrings.get('download', isArabic),
                        onTap: () => _showActionSnack(
                          isArabic ? 'جاري التحميل...' : 'Downloading...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionChip(
                        icon: Icons.share_rounded,
                        label: AppStrings.get('share', isArabic),
                        onTap: () => _showActionSnack(
                          isArabic ? 'جاري المشاركة...' : 'Sharing...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionChip(
                        icon: Icons.bookmark_rounded,
                        label: AppStrings.get('save', isArabic),
                        onTap: () => _showActionSnack(
                          isArabic ? 'تم الحفظ في المعرض' : 'Saved to gallery',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: AiGlowCard(
                  title: isArabic ? 'مسافر عبر الزمن' : 'Time Traveler AI',
                  description: isArabic
                      ? 'ارفع صورة سيلفي واختر قالباً لإنشاء صورة تاريخية مذهلة'
                      : 'Upload a selfie and pick a template to create a stunning historical portrait',
                  buttonLabel: isArabic ? 'جرب الآن' : 'Try Now',
                  onTap: () {
                    setState(() {
                      _hasUpload = true;
                      _selectedTemplate ??= templates.first;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({
    required this.hasUpload,
    required this.isArabic,
    required this.onTap,
  });

  final bool hasUpload;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: hasUpload ? AppColors.desertGold : AppColors.sandBeige,
            width: hasUpload ? 2 : 1.5,
          ),
          gradient: hasUpload
              ? null
              : LinearGradient(
                  colors: [
                    AppColors.sandBeige.withValues(alpha: 0.2),
                    AppColors.ivoryWhite,
                  ],
                ),
        ),
        child: hasUpload
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 2),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const AppNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
                      borderRadius: 0,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.desertGold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              isArabic ? 'تم الرفع' : 'Uploaded',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.desertGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 32,
                      color: AppColors.desertGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'اضغط لرفع صورتك' : 'Tap to upload your photo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? 'JPG أو PNG' : 'JPG or PNG',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ).animate(target: hasUpload ? 1 : 0).shimmer(
            duration: 1200.ms,
            color: AppColors.desertGold.withValues(alpha: 0.1),
          ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isArabic,
    required this.selected,
    required this.onTap,
  });

  final AiTemplate template;
  final bool isArabic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: selected ? AppColors.desertGold : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.desertGold.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: template.imageUrl, borderRadius: 0),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 10,
                child: Text(
                  isArabic ? template.nameAr : template.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: AppColors.desertGold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BeforeAfterSlider extends StatelessWidget {
  const _BeforeAfterSlider({
    required this.beforeUrl,
    required this.afterUrl,
    required this.sliderPosition,
    required this.onSlide,
  });

  final String beforeUrl;
  final String afterUrl;
  final double sliderPosition;
  final ValueChanged<double> onSlide;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final dividerX = width * sliderPosition;

            return Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(imageUrl: afterUrl, borderRadius: 0),
                ClipRect(
                  clipper: _RectClipper(dividerX),
                  child: AppNetworkImage(imageUrl: beforeUrl, borderRadius: 0),
                ),
                Positioned(
                  left: dividerX - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          size: 20,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _LabelBadge(text: 'Before'),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _LabelBadge(text: 'After'),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      final localX = details.localPosition.dx.clamp(0, width);
                      onSlide(localX / width);
                    },
                    onTapDown: (details) {
                      final localX = details.localPosition.dx.clamp(0, width);
                      onSlide(localX / width);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RectClipper extends CustomClipper<Rect> {
  _RectClipper(this.width);
  final double width;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _RectClipper oldClipper) =>
      oldClipper.width != width;
}

class _LabelBadge extends StatelessWidget {
  const _LabelBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sandBeige.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: AppColors.desertGold, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
