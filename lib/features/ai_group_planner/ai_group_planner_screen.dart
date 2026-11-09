import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/ai_glow_card.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';

class AiGroupPlannerScreen extends StatefulWidget {
  const AiGroupPlannerScreen({super.key});

  @override
  State<AiGroupPlannerScreen> createState() => _AiGroupPlannerScreenState();
}

class _AiGroupPlannerScreenState extends State<AiGroupPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController(text: 'Petra & Wadi Rum');
  final _groupSizeController = TextEditingController(text: '8');
  final _budgetController = TextEditingController(text: '500 JOD');
  final _durationController = TextEditingController(text: '3 days');

  String _activityType = 'hiking';
  bool _isGenerating = false;
  bool _showResults = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _groupSizeController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isGenerating = true;
      _showResults = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مخطط الرحلات الجماعية' : 'AI Group Planner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            AiGlowCard(
              title: isArabic ? 'خطط رحلتك الجماعية' : 'Plan Your Group Trip',
              description: isArabic
                  ? 'الذكاء الاصطناعي يصمم مساراً مثالياً لمجموعتك'
                  : 'AI crafts the perfect itinerary for your group',
              buttonLabel: isArabic ? 'ابدأ' : 'Get Started',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: isArabic ? 'تفاصيل الرحلة' : 'Trip Details',
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _groupSizeController,
                      label: isArabic ? 'حجم المجموعة' : 'Group Size',
                      icon: Icons.groups,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _budgetController,
                      label: isArabic ? 'الميزانية' : 'Budget',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _destinationController,
                      label: isArabic ? 'الوجهة' : 'Destination',
                      icon: Icons.place_outlined,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      controller: _durationController,
                      label: isArabic ? 'المدة' : 'Duration',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'نوع النشاط' : 'Activity Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'hiking',
                        'camping',
                        'photography',
                        'food',
                        'cultural',
                      ].map((type) {
                        final selected = _activityType == type;
                        return FilterChip(
                          label: Text(AppStrings.get(type, isArabic)),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _activityType = type),
                          selectedColor: AppColors.desertGold,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: isArabic ? 'إنشاء الخطة' : 'Generate Plan',
                      icon: Icons.auto_awesome,
                      isLoading: _isGenerating,
                      onPressed: _generatePlan,
                      width: double.infinity,
                      gradient: AppColors.aiGlow,
                    ),
                  ],
                ),
              ),
            ),
            if (_showResults) ...[
              const SizedBox(height: 32),
              SectionHeader(
                title: isArabic ? 'نتائج الذكاء الاصطناعي' : 'AI Results',
              ),
              const SizedBox(height: 12),
              _AiResultCard(
                isArabic: isArabic,
                title: isArabic ? 'المسار المقترح' : 'Suggested Itinerary',
                icon: Icons.route,
                gradient: AppColors.desertGradient,
                children: [
                  _ItineraryDay(
                    day: isArabic ? 'اليوم 1' : 'Day 1',
                    activity: isArabic
                        ? 'وصول البتراء — Treasury & Siq'
                        : 'Arrive Petra — Treasury & Siq',
                  ),
                  _ItineraryDay(
                    day: isArabic ? 'اليوم 2' : 'Day 2',
                    activity: isArabic
                        ? 'مسار البتراء الخلفي مع Ajloun Hikers'
                        : 'Petra Back Trail with Ajloun Hikers',
                  ),
                  _ItineraryDay(
                    day: isArabic ? 'اليوم 3' : 'Day 3',
                    activity: isArabic
                        ? 'تخييم وادي رم — Bedouin Stargazers'
                        : 'Wadi Rum Camping — Bedouin Stargazers',
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              _AiResultCard(
                isArabic: isArabic,
                title: isArabic ? 'تفصيل التكلفة' : 'Cost Breakdown',
                icon: Icons.receipt_long,
                children: [
                  _CostRow(
                    label: isArabic ? 'الإقامة' : 'Accommodation',
                    value: '180 JOD',
                  ),
                  _CostRow(
                    label: isArabic ? 'الأنشطة' : 'Activities',
                    value: '145 JOD',
                  ),
                  _CostRow(
                    label: isArabic ? 'المواصلات' : 'Transport',
                    value: '95 JOD',
                  ),
                  _CostRow(
                    label: isArabic ? 'الطعام' : 'Food',
                    value: '80 JOD',
                    isTotal: false,
                  ),
                  const Divider(),
                  _CostRow(
                    label: isArabic ? 'الإجمالي' : 'Total',
                    value: '500 JOD',
                    isTotal: true,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
              _AiResultCard(
                isArabic: isArabic,
                title: isArabic ? 'الطقس المتوقع' : 'Weather Forecast',
                icon: Icons.wb_sunny_outlined,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat,
                          color: AppColors.desertGold, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? '28°C — مشمس' : '28°C — Sunny',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              isArabic
                                  ? 'مثالي للتنزه والتخييم'
                                  : 'Perfect for hiking and camping',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              _AiResultCard(
                isArabic: isArabic,
                title: isArabic ? 'توصيات الطعام' : 'Food Recommendations',
                icon: Icons.restaurant,
                children: [
                  _RecommendationTile(
                    title: isArabic ? 'مطعم البتراء التقليدي' : 'Petra Traditional Restaurant',
                    subtitle: isArabic ? 'منسف أردني أصيل' : 'Authentic Jordanian Mansaf',
                  ),
                  _RecommendationTile(
                    title: isArabic ? 'مخيم بدوي وادي رم' : 'Wadi Rum Bedouin Camp',
                    subtitle: isArabic ? 'زرب وشاي بدوي' : 'Zarb & Bedouin tea',
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              _AiResultCard(
                isArabic: isArabic,
                title: isArabic ? 'المواصلات' : 'Transport',
                icon: Icons.directions_bus,
                children: [
                  _RecommendationTile(
                    title: isArabic ? 'حافلة جماعية' : 'Group Shuttle',
                    subtitle: isArabic
                        ? 'من عمان — 7:00 صباحاً'
                        : 'From Amman — 7:00 AM departure',
                  ),
                  _RecommendationTile(
                    title: isArabic ? 'سيارات 4x4' : '4x4 Desert Vehicles',
                    subtitle: isArabic
                        ? 'للوصول لمخيم وادي رم'
                        : 'For Wadi Rum camp access',
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.desertGold),
      ),
    );
  }
}

class _AiResultCard extends StatelessWidget {
  const _AiResultCard({
    required this.isArabic,
    required this.title,
    required this.icon,
    required this.children,
    this.gradient,
  });

  final bool isArabic;
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GlassCard(
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (gradient!.colors.first).withValues(alpha: 0.15),
                  (gradient!.colors.last).withValues(alpha: 0.08),
                ],
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.desertGold),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ItineraryDay extends StatelessWidget {
  const _ItineraryDay({required this.day, required this.activity});

  final String day;
  final String activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.desertGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: AppColors.desertGold,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(activity, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.desertGold : null,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sandBeige.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.emerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
