import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/jordan_place_seed.dart';
import 'saved_plans_store.dart';

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  late Future<List<SavedPlanRecord>> _plans;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _plans = SavedPlansStore.instance.load();

  Future<void> _delete(SavedPlanRecord plan, bool isArabic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isArabic ? 'حذف الخطة؟' : 'Delete this plan?'),
            content: Text(
              isArabic
                  ? 'سيتم حذف «${plan.destination}» من الخطط المحفوظة على هذا الجهاز.'
                  : '“${plan.destination}” will be removed from the plans saved on this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(isArabic ? 'حذف' : 'Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await SavedPlansStore.instance.delete(plan.id);
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'تم حذف الخطة.' : 'Plan deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذر حذف الخطة: $error'
                : 'Could not delete plan: $error',
          ),
        ),
      );
    }
  }

  Future<void> _open(SavedPlanRecord plan, bool isArabic) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (sheetContext) => _PlanDetailsSheet(
            plan: plan,
            isArabic: isArabic,
            onAdjust: () {
              Navigator.pop(sheetContext);
              context.push('/ai-planner', extra: plan);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'خططي' : 'My Plans')),
      body: FutureBuilder<List<SavedPlanRecord>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline_rounded,
              title: isArabic ? 'تعذر تحميل الخطط' : 'Could not load plans',
              detail: '${snapshot.error}',
              action: TextButton.icon(
                onPressed: () => setState(_reload),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
              ),
            );
          }
          final plans = snapshot.data ?? const <SavedPlanRecord>[];
          if (plans.isEmpty) {
            return _MessageState(
              icon: Icons.bookmark_add_outlined,
              title: isArabic ? 'لا توجد خطط محفوظة بعد' : 'No saved plans yet',
              detail:
                  isArabic
                      ? 'أنشئ برنامجًا في مخطط الرحلات ثم اضغط «احفظ الخطة». ستظهر هنا.'
                      : 'Create an itinerary in Plan My Day and tap “Save Plan”. It will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = plans[index];
                final stopCount = plan.days.fold<int>(
                  0,
                  (sum, day) => sum + day.placeIds.length,
                );
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _open(plan, isArabic),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.map_rounded,
                                color: AppColors.desertGold,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  plan.destination,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                tooltip: isArabic ? 'حذف الخطة' : 'Delete plan',
                                onPressed: () => _delete(plan, isArabic),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          Text(
                            isArabic
                                ? '${plan.daysCount} أيام · ${plan.travelers} مسافرين · ${plan.budget.toStringAsFixed(0)} د.أ ميزانية'
                                : '${plan.daysCount} days · ${plan.travelers} travelers · ${plan.budget.toStringAsFixed(0)} JOD budget',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? '$stopCount أماكن · الرسوم المعروفة ${plan.estimatedLow.toStringAsFixed(0)}–${plan.estimatedHigh.toStringAsFixed(0)} د.أ'
                                : '$stopCount places · known activity fees ${plan.estimatedLow.toStringAsFixed(0)}–${plan.estimatedHigh.toStringAsFixed(0)} JOD',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (plan.unpricedPlaceIds.isNotEmpty)
                            Text(
                              isArabic
                                ? '${plan.unpricedPlaceIds.length} وجهات بأسعار غير معروفة؛ الإجمالي غير مكتمل.'
                                : '${plan.unpricedPlaceIds.length} unpriced stops — total cost unknown.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: () => _open(plan, isArabic),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(isArabic ? 'عرض الخطة' : 'Open plan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PlanDetailsSheet extends StatelessWidget {
  const _PlanDetailsSheet({
    required this.plan,
    required this.isArabic,
    required this.onAdjust,
  });
  final SavedPlanRecord plan;
  final bool isArabic;
  final VoidCallback onAdjust;

  String _placeName(String id) {
    for (final place in JordanPlaceSeed.places) {
      if (place.id == id) return isArabic ? place.nameAr : place.name;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FractionallySizedBox(
      heightFactor: .88,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            plan.destination,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? '${plan.daysCount} أيام · ${plan.travelers} مسافرين · الميزانية ${plan.budget.toStringAsFixed(2)} د.أ'
                : '${plan.daysCount} days · ${plan.travelers} travelers · budget ${plan.budget.toStringAsFixed(2)} JOD',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAdjust,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(isArabic ? 'تعديل مع المخطط' : 'Adjust with planner'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.desertGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'تقدير الأنشطة: ${plan.estimatedLow.toStringAsFixed(2)}–${plan.estimatedHigh.toStringAsFixed(2)} د.أ'
                : 'Activity estimate: ${plan.estimatedLow.toStringAsFixed(2)}–${plan.estimatedHigh.toStringAsFixed(2)} JOD',
          ),
          if (plan.unpricedPlaceIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isArabic
                  ? 'تحذير: ${plan.unpricedPlaceIds.length} وجهات دون رسوم مؤكدة. هذا تقدير جزئي ولا يثبت أن الرحلة ضمن الميزانية.'
                  : 'Cost warning: ${plan.unpricedPlaceIds.length} stops have unknown prices. These subtotals are incomplete and cannot confirm the trip budget.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (plan.travelDate.isNotEmpty)
            Text(
              isArabic
                  ? 'تاريخ الرحلة: ${plan.travelDate}'
                  : 'Travel date: ${plan.travelDate}',
            ),
          Text(
            isArabic
                ? 'نقطة البداية: ${plan.startLocation}'
                : 'Starting point: ${plan.startLocation}',
          ),
          if (plan.mobilityNeeds.isNotEmpty)
            Text(
              isArabic
                  ? 'الحركة: ${plan.mobilityNeeds}'
                  : 'Mobility: ${plan.mobilityNeeds}',
            ),
          if (plan.accessibilityNeeds.isNotEmpty)
            Text(
              isArabic
                  ? 'إمكانية الوصول: ${plan.accessibilityNeeds}'
                  : 'Accessibility: ${plan.accessibilityNeeds}',
            ),
          if (plan.dietaryNeeds.isNotEmpty)
            Text(
              isArabic
                  ? 'الغذاء: ${plan.dietaryNeeds}'
                  : 'Dietary: ${plan.dietaryNeeds}',
            ),
          const SizedBox(height: 16),
          for (var index = 0; index < plan.days.length; index++) ...[
            Text(
              isArabic
                  ? 'اليوم ${index + 1} · ${plan.days[index].region}'
                  : 'Day ${index + 1} · ${plan.days[index].region}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            for (final id in plan.days[index].placeIds)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.place_outlined,
                  color: AppColors.desertGold,
                ),
                title: Text(_placeName(id)),
                subtitle: _priceNote(id),
              ),
            const Divider(),
          ],
          Text(
            isArabic
                ? 'حُفظت الأسعار كمراجع وقت إنشاء الخطة. تحقق منها قبل الحجز.'
                : 'Price references were saved with this plan. Confirm prices before booking.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );

  Widget? _priceNote(String id) {
    final snapshot = plan.priceSnapshots[id];
    if (snapshot == null) {
      return Text(isArabic ? 'السعر غير محفوظ' : 'No saved price reference');
    }
    final source = snapshot['sourceName'] as String? ?? '';
    final checked = snapshot['checkedAt'] as String? ?? '';
    final estimate = snapshot['label'] as String? ?? '';
    final details = [
      estimate,
      if (source.isNotEmpty) source,
      if (checked.isNotEmpty) checked,
    ].join(' · ');
    final url = snapshot['sourceUrl'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(details),
        if (url.isNotEmpty)
          TextButton.icon(
            onPressed:
                () => launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                ),
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: Text(isArabic ? 'افتح مصدر السعر' : 'Open price source'),
          ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });
  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.desertGold),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(detail, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}
