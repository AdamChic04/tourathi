import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';
import 'jordan_price_catalog.dart';
import 'jordan_visit_info.dart';
import 'saved_plans_store.dart';
import 'trip_plan_generator.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key, this.initialPlan});
  final SavedPlanRecord? initialPlan;

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

enum _TripPace { relaxed, balanced, active }

enum _Discovery { famous, local, mixed }

class _PlannerDay {
  const _PlannerDay(this.region, this.places);
  final String region;
  final List<Place> places;
}

class _TripPlan {
  const _TripPlan({
    required this.days,
    required this.estimatedCost,
    required this.budget,
    required this.travelers,
    required this.suggestedBudget,
    required this.estimatedLow,
    required this.estimatedHigh,
    required this.usedAi,
    required this.statusMessage,
    required this.explanation,
    required this.placeReasons,
    required this.visitorClass,
    required this.otherCostsAllowance,
    required this.destination,
    required this.travelDate,
    required this.startLocation,
    required this.mobilityNeeds,
    required this.accessibilityNeeds,
    required this.dietaryNeeds,
    required this.daysCount,
    required this.additionalRequests,
    required this.alternatives,
  });

  final List<_PlannerDay> days;
  final double estimatedCost;
  final double budget;
  final int travelers;
  final double suggestedBudget;
  final double estimatedLow;
  final double estimatedHigh;
  final bool usedAi;
  final String statusMessage;
  final String explanation;
  final Map<String, String> placeReasons;
  final VisitorRateClass visitorClass;
  final double otherCostsAllowance;
  final String destination;
  final String travelDate;
  final String startLocation;
  final String mobilityNeeds;
  final String accessibilityNeeds;
  final String dietaryNeeds;
  final int daysCount;
  final String additionalRequests;
  final List<Place> alternatives;
}

/// A local itinerary optimizer. The source catalog has no live prices,
/// coordinates, or opening hours, so cost figures are explicitly estimates.
class _AiPlannerScreenState extends State<AiPlannerScreen> {
  final _budgetController = TextEditingController(text: '100');
  final _travelersController = TextEditingController(text: '2');
  final _daysController = TextEditingController(text: '3');
  final _startController = TextEditingController(text: 'Amman');
  final _mobilityController = TextEditingController();
  final _accessibilityController = TextEditingController();
  final _dietaryController = TextEditingController();
  final _otherCostsController = TextEditingController(text: '0');
  final _extraRequestsController = TextEditingController();
  final _chatController = TextEditingController();
  final _generator = TripPlanGenerator();
  final List<({bool fromUser, String text})> _chatMessages = [];
  DateTime? _travelDate;
  String _destination = 'Jordan';
  bool _isSendingMessage = false;
  final Set<String> _interests = {};
  _TripPace _pace = _TripPace.balanced;
  _Discovery _discovery = _Discovery.mixed;
  _TripPlan? _plan;
  String? _error;
  bool _isBuilding = false;
  bool _isSaving = false;
  String? _savedPlanId;
  bool _hasUnsavedChanges = false;
  bool _intro = true;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final saved = widget.initialPlan;
    if (saved != null) {
      _budgetController.text = saved.budget.toStringAsFixed(2);
      _travelersController.text = saved.travelers.toString();
      _daysController.text = saved.daysCount.toString();
      _startController.text = saved.startLocation;
      _mobilityController.text = saved.mobilityNeeds;
      _accessibilityController.text = saved.accessibilityNeeds;
      _dietaryController.text = saved.dietaryNeeds;
      _extraRequestsController.text = saved.additionalRequests;
      _otherCostsController.text = saved.otherCostsAllowance.toStringAsFixed(2);
      _destination = saved.destination;
      _travelDate = DateTime.tryParse(saved.travelDate);
      _interests.addAll(saved.interests);
      _pace = _TripPace.values.firstWhere(
        (value) => value.name == saved.pace,
        orElse: () => _TripPace.balanced,
      );
      _discovery = _Discovery.values.firstWhere(
        (value) => value.name == saved.discovery,
        orElse: () => _Discovery.mixed,
      );
      _savedPlanId = saved.id;
      _plan = _TripPlan(
        days: saved.days
            .map((day) => _PlannerDay(day.region, _placesForIds(day.placeIds)))
            .where((day) => day.places.isNotEmpty)
            .toList(growable: false),
        estimatedCost: (saved.estimatedLow + saved.estimatedHigh) / 2,
        budget: saved.budget,
        travelers: saved.travelers,
        suggestedBudget: saved.estimatedHigh,
        estimatedLow: saved.estimatedLow,
        estimatedHigh: saved.estimatedHigh,
        usedAi: saved.usedAi,
        statusMessage:
            saved.usedAi ? 'AI generated itinerary' : 'Local catalog itinerary',
        explanation: saved.explanation,
        placeReasons: saved.placeReasons,
        visitorClass: VisitorRateClass.values.firstWhere(
          (value) => value.name == saved.visitorClass,
          orElse: () => VisitorRateClass.international,
        ),
        otherCostsAllowance: saved.otherCostsAllowance,
        destination: saved.destination,
        travelDate: saved.travelDate,
        startLocation: saved.startLocation,
        mobilityNeeds: saved.mobilityNeeds,
        accessibilityNeeds: saved.accessibilityNeeds,
        dietaryNeeds: saved.dietaryNeeds,
        daysCount: saved.daysCount,
        additionalRequests: saved.additionalRequests,
        alternatives: const [],
      );
      _step = 6;
      _intro = false;
      _chatMessages.add((
        fromUser: false,
        text:
            'Plan reopened. Ask me to change the stops, pace, cost, or interests.',
      ));
      _chatMessages.insertAll(
        0,
        saved.chatHistory.take(20).map((entry) {
          final isTraveler = entry.startsWith('Traveler: ');
          final splitAt = entry.indexOf(': ');
          return (
            fromUser: isTraveler,
            text: splitAt < 0 ? entry : entry.substring(splitAt + 2),
          );
        }),
      );
    }
    Future<void>.delayed(const Duration(milliseconds: 380), () {
      if (mounted) setState(() => _intro = false);
    });
  }

  List<Place> _placesForIds(List<String> ids) {
    final byId = {for (final place in JordanPlaceSeed.places) place.id: place};
    return ids.map((id) => byId[id]).whereType<Place>().toList(growable: false);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _travelersController.dispose();
    _daysController.dispose();
    _startController.dispose();
    _mobilityController.dispose();
    _accessibilityController.dispose();
    _dietaryController.dispose();
    _otherCostsController.dispose();
    _extraRequestsController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _buildPlan({String? requestText}) async {
    final budget = double.tryParse(
      _budgetController.text.trim().replaceAll(',', '.'),
    );
    final travelers = int.tryParse(_travelersController.text.trim());
    final requestedDays = int.tryParse(_daysController.text.trim());
    final otherCosts =
        double.tryParse(
          _otherCostsController.text.trim().replaceAll(',', '.'),
        ) ??
        0;
    if (budget == null ||
        budget <= 0 ||
        travelers == null ||
        travelers < 1 ||
        travelers > 30 ||
        requestedDays == null ||
        requestedDays < 1 ||
        requestedDays > 30 ||
        otherCosts < 0 ||
        otherCosts > budget) {
      setState(
        () =>
            _error =
                'أدخل ميزانية صحيحة، وعدد مسافرين من 1 إلى 30، ومدة من 1 إلى 30 يوماً.',
      );
      return;
    }
    setState(() {
      _isBuilding = true;
      _error = null;
      if (requestText == null) _plan = null;
    });

    try {
      final request = PlannerPreferences(
        destination: _destination,
        budget: budget,
        travelers: travelers,
        days: requestedDays,
        interests: Set.unmodifiable(_interests),
        pace: _pace.name,
        discovery: _discovery.name,
        visitorClass: VisitorRateClass.international,
        travelDate:
            _travelDate == null
                ? ''
                : '${_travelDate!.year.toString().padLeft(4, '0')}-${_travelDate!.month.toString().padLeft(2, '0')}-${_travelDate!.day.toString().padLeft(2, '0')}',
        startLocation: _startController.text.trim(),
        mobilityNeeds: _mobilityController.text.trim(),
        accessibilityNeeds: _accessibilityController.text.trim(),
        dietaryNeeds: _dietaryController.text.trim(),
        otherCostsAllowance: otherCosts,
        additionalRequests:
            requestText?.trim() ?? _extraRequestsController.text.trim(),
        currentPlanIds:
            _plan?.days
                .map((day) => day.places.map((place) => place.id).toList())
                .toList() ??
            const [],
        conversationHistory: _chatMessages
            .take(20)
            .map(
              (message) => {
                'role': message.fromUser ? 'traveler' : 'planner',
                'content':
                    message.text.length > 1200
                        ? message.text.substring(0, 1200)
                        : message.text,
              },
            )
            .toList(growable: false),
        language: _isArabic ? 'ar' : 'en',
      );
      final generated = await _generator.generate(request);
      if (!mounted) return;
      if (requestText != null && !generated.usedAi) {
        setState(() {
          _isBuilding = false;
          _chatMessages.add((
            fromUser: false,
            text:
                'I could not apply that change because live AI is unavailable. Your current plan is unchanged. ${generated.statusMessage}',
          ));
        });
        return;
      }
      final days = generated.days
          .map((day) => _PlannerDay(day.region, day.places))
          .toList(growable: false);
      setState(() {
        _plan = _TripPlan(
          days: List.unmodifiable(days),
          estimatedCost: (generated.estimatedLow + generated.estimatedHigh) / 2,
          budget: budget,
          travelers: travelers,
          suggestedBudget: generated.suggestedBudget,
          estimatedLow: generated.estimatedLow,
          estimatedHigh: generated.estimatedHigh,
          usedAi: generated.usedAi,
          statusMessage: generated.statusMessage,
          explanation: generated.explanation,
          placeReasons: generated.placeReasons,
          visitorClass: request.visitorClass,
          otherCostsAllowance: request.otherCostsAllowance,
          destination: request.destination,
          travelDate: request.travelDate,
          startLocation: request.startLocation,
          mobilityNeeds: request.mobilityNeeds,
          accessibilityNeeds: request.accessibilityNeeds,
          dietaryNeeds: request.dietaryNeeds,
          daysCount: request.days,
          additionalRequests: request.additionalRequests,
          alternatives: generated.alternatives,
        );
        _isBuilding = false;
        _step = 6;
        _hasUnsavedChanges = true;
        if (requestText != null) {
          _chatMessages.add((
            fromUser: false,
            text:
                generated.usedAi
                    ? generated.explanation
                    : 'This request needs the configured AI service. I rebuilt the plan from the available catalogue. ${generated.statusMessage}',
          ));
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isBuilding = false;
        _error =
            _isArabic
                ? 'تعذر إنشاء الخطة: $error'
                : 'Could not create the itinerary: $error';
        if (requestText != null) {
          _chatMessages.add((fromUser: false, text: _error!));
        }
      });
    }
  }

  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isSendingMessage || _plan == null) return;
    setState(() {
      _chatController.clear();
      _chatMessages.add((fromUser: true, text: text));
      _hasUnsavedChanges = true;
      _isSendingMessage = true;
    });
    await _buildPlan(requestText: text);
    if (mounted) setState(() => _isSendingMessage = false);
  }

  String _money(double amount) => '${amount.toStringAsFixed(2)} JOD';

  int get _travelers => int.tryParse(_travelersController.text) ?? 2;
  int get _tripDays => int.tryParse(_daysController.text) ?? 3;

  void _setTravelers(int value) {
    _travelersController.text = value.clamp(1, 30).toString();
    setState(() {});
  }

  void _setDays(int value) {
    _daysController.text = value.clamp(1, 30).toString();
    setState(() {});
  }

  void _restart() {
    setState(() {
      _step = 0;
      _budgetController.text = '100';
      _travelersController.text = '2';
      _daysController.text = '3';
      _interests.clear();
      _pace = _TripPace.balanced;
      _discovery = _Discovery.mixed;
      _destination = 'Jordan';
      _travelDate = null;
      _startController.text = 'Amman';
      _mobilityController.clear();
      _accessibilityController.clear();
      _dietaryController.clear();
      _otherCostsController.text = '0';
      _extraRequestsController.clear();
      _plan = null;
      _savedPlanId = null;
      _hasUnsavedChanges = false;
      _chatMessages.clear();
      _error = null;
    });
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      final budget = double.tryParse(
        _budgetController.text.trim().replaceAll(',', '.'),
      );
      if (budget == null || budget <= 0 || budget > 100000) {
        setState(
          () =>
              _error =
                  _isArabic
                      ? 'أدخل ميزانية أكبر من صفر بالدينار الأردني.'
                      : 'Enter a budget greater than zero in JOD.',
        );
        return;
      }
    }
    if (_step < 5) {
      setState(() {
        _error = null;
        _step++;
      });
    } else {
      _buildPlan();
    }
  }

  void _backStep() {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      if (_step > 0) _step--;
    });
  }

  bool get _isArabic =>
      Provider.of<AppProvider>(context, listen: false).isArabic;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'خطط ليومي' : 'Plan My Day'),
        actions: [
          IconButton(
            tooltip: isArabic ? 'خططي' : 'My Plans',
            onPressed: () => context.push('/my-plans'),
            icon: const Icon(Icons.folder_open_rounded),
          ),
          if (_step == 6)
            IconButton(
              tooltip: isArabic ? 'خطة جديدة' : 'New plan',
              onPressed: _restart,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body:
          _intro
              ? _introView(isArabic)
              : _isBuilding
              ? _loadingView(isArabic)
              : _wizardView(isArabic),
    );
  }

  Widget _introView(bool isArabic) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .82, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder:
            (context, value, child) => Opacity(
              opacity: value.clamp(0, 1),
              child: Transform.scale(scale: value, child: child),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.desertGradient,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isArabic ? 'مغامرتك، على ذوقك' : 'Your day, your way',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أجب عن بعض الأسئلة السريعة لنرتب لك برنامجًا من أماكن الأردن.'
                  : 'A few quick choices and we’ll shape a Jordan day around you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _loadingView(bool isArabic) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 76,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.desertGold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic
                ? 'نرتب لك أيام الأردن…'
                : 'Putting your Jordan days together…',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            isArabic
                ? 'نطابق اهتماماتك وميزانيتك مع دليل الأماكن.'
                : 'Matching your interests and budget with the place catalog.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );

  Widget _wizardView(bool isArabic) {
    final result = _step == 6;
    return Column(
      children: [
        if (!result) _progressHeader(isArabic),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder:
                (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(.035, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
            child:
                result
                    ? _resultView(isArabic, key: const ValueKey('result'))
                    : _questionView(isArabic, key: ValueKey(_step)),
          ),
        ),
        if (!result) _stepActions(isArabic),
        if (result) _resultActions(isArabic),
      ],
    );
  }

  Widget _progressHeader(bool isArabic) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'الخطوة ${_step + 1} من 6' : 'STEP ${_step + 1} OF 6',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmBrown,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${((_step + 1) / 6 * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: (_step + 1) / 6,
            minHeight: 5,
            color: AppColors.desertGold,
            backgroundColor: AppColors.sandBeige.withValues(alpha: .45),
          ),
        ),
      ],
    ),
  );

  String _questionTitle(bool ar) => switch (_step) {
    0 =>
      ar
          ? 'ما ميزانيتك الإجمالية لهذه الرحلة؟'
          : 'What’s your total budget for this trip?',
    1 =>
      ar ? 'كم شخصًا سيسافر معك؟' : 'How many people are traveling with you?',
    2 => ar ? 'كم يومًا ستستغرق رحلتك؟' : 'How many days is your trip?',
    3 => ar ? 'ما الذي يهمك اكتشافه؟' : 'What are you interested in?',
    4 =>
      ar
          ? 'ما الوتيرة المناسبة لرحلتك؟'
          : 'What pace would you like for your trip?',
    _ =>
      ar
          ? 'ما نوع الأماكن التي تحب اكتشافها؟'
          : 'What kind of places would you like to discover?',
  };

  String _questionSubtitle(bool ar) => switch (_step) {
    0 =>
      ar
          ? 'سنستخدم هذا المبلغ لترتيب الأنشطة المقترحة.'
          : 'We’ll use this amount to shape the activities we suggest.',
    1 =>
      ar
          ? 'سنحسب تقدير الأنشطة لمجموعتك.'
          : 'We’ll tailor the activity estimate for your group.',
    2 =>
      ar
          ? 'اختر عدد الأيام التي تريد التخطيط لها.'
          : 'Choose how many days you want us to plan.',
    3 =>
      ar
          ? 'اختر كل ما يناسبك؛ يمكنك تحديد أكثر من خيار.'
          : 'Pick as many as you like. You can select more than one.',
    4 =>
      ar
          ? 'اختر الإيقاع الذي يناسب يومك.'
          : 'Set the tempo that feels right for you.',
    _ =>
      ar
          ? 'اختر مزيجًا متوازنًا أو نمطًا محددًا.'
          : 'Choose a balanced mix or a discovery style.',
  };

  IconData _questionIcon() => switch (_step) {
    0 => Icons.account_balance_wallet_outlined,
    1 => Icons.groups_2_outlined,
    2 => Icons.calendar_month_outlined,
    3 => Icons.interests_outlined,
    4 => Icons.speed_rounded,
    _ => Icons.explore_outlined,
  };

  Widget _questionView(bool isArabic, {required Key key}) =>
      SingleChildScrollView(
        key: key,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.desertGold.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_questionIcon(), color: AppColors.warmBrown),
            ),
            const SizedBox(height: 18),
            Text(
              _questionTitle(isArabic),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(height: 1.18),
            ),
            const SizedBox(height: 8),
            Text(
              _questionSubtitle(isArabic),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.warmBrown,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 23),
            _stepContent(isArabic),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      );

  Widget _stepContent(bool isArabic) => switch (_step) {
    0 => TextField(
      controller: _budgetController,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _continue(),
      style: Theme.of(context).textTheme.headlineSmall,
      decoration: InputDecoration(
        labelText: isArabic ? 'الميزانية الإجمالية' : 'Total budget',
        hintText: isArabic ? 'مثال: 100' : 'e.g. 100',
        suffixText: 'JOD',
        prefixIcon: const Icon(
          Icons.account_balance_wallet_outlined,
          color: AppColors.desertGold,
        ),
      ),
    ),
    1 => _counterCard(
      isArabic ? 'مسافرون' : 'Travelers',
      _travelers,
      1,
      30,
      _setTravelers,
      Icons.people_alt_outlined,
    ),
    2 => _counterCard(
      isArabic ? 'أيام' : 'Days',
      _tripDays,
      1,
      30,
      _setDays,
      Icons.wb_sunny_outlined,
    ),
    3 => _interestOptions(isArabic),
    4 => _choiceCards(
      isArabic,
      [
        (
          'relaxed',
          isArabic ? 'هادئة' : 'Relaxed',
          isArabic ? 'وقت أوسع بين الزيارات' : 'More room to take it in',
          Icons.spa_outlined,
        ),
        (
          'balanced',
          isArabic ? 'متوازنة' : 'Balanced',
          isArabic ? 'مزيج من النشاط والراحة' : 'A little of everything',
          Icons.balance_outlined,
        ),
        (
          'active',
          isArabic ? 'مكثفة' : 'Active',
          isArabic ? 'محطات أكثر يوميًا' : 'More stops each day',
          Icons.bolt_outlined,
        ),
      ],
      _pace.name,
      (value) => setState(() => _pace = _TripPace.values.byName(value)),
    ),
    _ => Column(
      children: [
        _choiceCards(
          isArabic,
          [
            (
              'mixed',
              isArabic ? 'مزيج من الأماكن' : 'A mix of places',
              isArabic ? 'معالم مع لمسات محلية' : 'Landmarks and local finds',
              Icons.auto_awesome_outlined,
            ),
            (
              'famous',
              isArabic ? 'معالم مشهورة' : 'Famous attractions',
              isArabic ? 'أماكن بارزة في الأردن' : 'Well-known Jordan sites',
              Icons.star_outline_rounded,
            ),
            (
              'local',
              isArabic ? 'جواهر محلية' : 'Local gems',
              isArabic
                  ? 'اكتشافات محلية مميزة'
                  : 'Distinctive local discoveries',
              Icons.diamond_outlined,
            ),
          ],
          _discovery.name,
          (value) =>
              setState(() => _discovery = _Discovery.values.byName(value)),
        ),
        const SizedBox(height: 16),
        _tripDetails(isArabic),
      ],
    ),
  };

  Widget _tripDetails(bool isArabic) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownButtonFormField<String>(
        value: _destination,
        decoration: InputDecoration(
          labelText: isArabic ? 'الوجهة' : 'Destination',
          prefixIcon: const Icon(Icons.map_outlined),
        ),
        items: [
          DropdownMenuItem(
            value: 'Jordan',
            child: Text(isArabic ? 'كل الأردن' : 'All Jordan'),
          ),
          for (final region in const [
            'Amman',
            'Balqa',
            'Zarqa',
            'Irbid',
            'Jerash',
            'Ajloun',
            'Mafraq',
            'Madaba',
            'Karak',
            'Tafilah',
            'Ma’an',
            'Aqaba',
          ])
            DropdownMenuItem(value: region, child: Text(region)),
        ],
        onChanged: (value) => setState(() => _destination = value ?? 'Jordan'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate:
                _travelDate ?? DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 730)),
          );
          if (date != null && mounted) setState(() => _travelDate = date);
        },
        icon: const Icon(Icons.event_outlined),
        label: Text(
          _travelDate == null
              ? (isArabic
                  ? 'اختياري: اختر تاريخ بدء الرحلة'
                  : 'Optional: choose your trip start date')
              : '${_travelDate!.year}-${_travelDate!.month.toString().padLeft(2, '0')}-${_travelDate!.day.toString().padLeft(2, '0')}',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _startController,
        decoration: InputDecoration(
          labelText: isArabic ? 'من أين ستبدأ؟' : 'Starting point',
          prefixIcon: const Icon(Icons.trip_origin_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _otherCostsController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText:
              isArabic
                  ? 'مخصص النقل والإقامة (اختياري)'
                  : 'Your transport and lodging allowance (optional)',
          prefixIcon: const Icon(Icons.hotel_outlined),
          suffixText: 'JOD',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _mobilityController,
        decoration: InputDecoration(
          labelText:
              isArabic
                  ? 'الحركة والتنقل (اختياري)'
                  : 'Mobility needs (optional)',
          hintText:
              isArabic ? 'مثل: مسافة مشي قصيرة' : 'e.g. limit walking distance',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _accessibilityController,
        decoration: InputDecoration(
          labelText:
              isArabic
                  ? 'إمكانية الوصول (اختياري)'
                  : 'Accessibility needs (optional)',
          hintText:
              isArabic
                  ? 'مثل: منحدرات للكراسي المتحركة'
                  : 'e.g. step-free access',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _dietaryController,
        decoration: InputDecoration(
          labelText:
              isArabic
                  ? 'التفضيلات الغذائية (اختياري)'
                  : 'Dietary preferences (optional)',
          hintText:
              isArabic
                  ? 'مثل: نباتي أو حساسية'
                  : 'e.g. vegetarian or allergies',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _extraRequestsController,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(
          labelText:
              isArabic
                  ? 'ماذا تريد أن يعرف المخطط؟'
                  : 'What else should the planner know?',
          hintText:
              isArabic
                  ? 'مثال: أفضّل الأماكن الهادئة ولا أريد مشيًا طويلًا.'
                  : 'For example: prefer quieter places and avoid long walks.',
          prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        isArabic
            ? 'سنمرر هذه التفضيلات للمخطط. لا توجد لدينا بيانات موثقة عن إمكانية الوصول أو المطاعم لكل مكان، لذا تحقق مباشرة قبل الزيارة.'
            : 'The planner will consider these notes. Verified accessibility and restaurant data are not available for every place; confirm with providers before visiting.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.warmBrown),
      ),
    ],
  );

  Widget _counterCard(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
    IconData icon,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.sandBeige.withValues(alpha: .65)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.desertGold.withValues(alpha: .13),
          child: Icon(icon, color: AppColors.warmBrown),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton.filledTonal(
          tooltip: _isArabic ? 'تقليل' : 'Decrease',
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 42,
          child: Semantics(
            label: '$label: $value',
            liveRegion: true,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: _isArabic ? 'زيادة' : 'Increase',
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
  );

  Widget _interestOptions(bool isArabic) {
    const options = <(String, String, String, IconData)>[
      (
        'culture',
        'Culture & Heritage',
        'الثقافة والتراث',
        Icons.account_balance_outlined,
      ),
      ('nature', 'Nature', 'الطبيعة', Icons.park_outlined),
      ('adventure', 'Adventure', 'المغامرة', Icons.hiking_rounded),
      ('food', 'Local Food', 'الطعام المحلي', Icons.restaurant_outlined),
      ('history', 'History', 'التاريخ', Icons.history_edu_outlined),
      (
        'religious',
        'Faith & Traditions',
        'الدين والتقاليد',
        Icons.mosque_outlined,
      ),
      ('shopping', 'Markets', 'الأسواق', Icons.storefront_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in options)
              SizedBox(
                width: width,
                child: _WizardOption(
                  selected: _interests.contains(item.$1),
                  icon: item.$4,
                  title: isArabic ? item.$3 : item.$2,
                  onTap:
                      () => setState(() {
                        if (!_interests.add(item.$1)) {
                          _interests.remove(item.$1);
                        }
                      }),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _choiceCards(
    bool isArabic,
    List<(String, String, String, IconData)> items,
    String selected,
    ValueChanged<String> onSelect,
  ) => Column(
    children: [
      for (final item in items) ...[
        _WizardOption(
          selected: selected == item.$1,
          icon: item.$4,
          title: item.$2,
          subtitle: item.$3,
          onTap: () => onSelect(item.$1),
          horizontal: true,
        ),
        const SizedBox(height: 10),
      ],
    ],
  );

  Widget _stepActions(bool isArabic) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          if (_step > 0) ...[
            OutlinedButton.icon(
              onPressed: _backStep,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(isArabic ? 'رجوع' : 'Back'),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: _continue,
              icon: Icon(
                _step == 5
                    ? Icons.auto_awesome_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                _step == 5
                    ? (isArabic ? 'أنشئ برنامجي' : 'Create my itinerary')
                    : (isArabic ? 'متابعة' : 'Continue'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.desertGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _resultView(bool isArabic, {required Key key}) => ListView(
    key: key,
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.desertGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic ? 'خطتك جاهزة' : 'Your itinerary is ready',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryPill(
                  '${_money(double.tryParse(_budgetController.text) ?? 0)} ${isArabic ? 'ميزانية' : 'budget'}',
                ),
                _SummaryPill(
                  '$_travelers ${isArabic ? 'مسافرين' : 'travelers'}',
                ),
                _SummaryPill('$_tripDays ${isArabic ? 'أيام' : 'days'}'),
                _SummaryPill(
                  isArabic
                      ? 'الوجهة: $_destination'
                      : 'Destination: $_destination',
                ),
                _SummaryPill(
                  '${_paceLabel(isArabic)} · ${_discoveryLabel(isArabic)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${isArabic ? 'الاهتمامات' : 'Interests'}: ${_interestLabel(isArabic)}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              isArabic
                  ? 'نقطة البداية: ${_startController.text.trim()}'
                  : 'Start: ${_startController.text.trim()}',
              style: const TextStyle(color: Colors.white),
            ),
            if (_travelDate != null)
              Text(
                isArabic
                    ? 'تاريخ الرحلة: ${_travelDate!.year}-${_travelDate!.month.toString().padLeft(2, '0')}-${_travelDate!.day.toString().padLeft(2, '0')}'
                    : 'Trip date: ${_travelDate!.year}-${_travelDate!.month.toString().padLeft(2, '0')}-${_travelDate!.day.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      if (_plan != null)
        _PlanResults(
          plan: _plan!,
          isArabic: isArabic,
          money: _money,
          onUseSuggested: _useSuggestedBudget,
          onBroadenDestination: _broadenDestination,
        ),
      if (_plan != null) ...[
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _plan!.usedAi
                          ? Icons.auto_awesome_rounded
                          : Icons.offline_bolt_rounded,
                      color: AppColors.desertGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _plan!.usedAi
                            ? (isArabic
                                ? 'خطة من الذكاء الاصطناعي'
                                : 'AI-generated plan')
                            : (isArabic
                                ? 'خطة محلية احتياطية'
                                : 'Local fallback plan'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _plan!.explanation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  _plan!.statusMessage,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.warmBrown),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _plannerChat(isArabic),
      ],
    ],
  );

  Widget _plannerChat(bool isArabic) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'عدّل خطتك بالمحادثة' : 'Adjust your plan by chat',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'اطلب تغييرًا مثل: اجعل اليوم الثاني أقل تكلفة، استبدل محطة، أو أضف المزيد من الطبيعة.'
                : 'Try: make day two cheaper, replace a stop, or add more nature.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final message in _chatMessages) ...[
            const SizedBox(height: 8),
            Align(
              alignment:
                  message.fromUser
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color:
                      message.fromUser
                          ? AppColors.desertGold.withValues(alpha: .16)
                          : AppColors.sandBeige.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(message.text),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendChatMessage(),
                  decoration: InputDecoration(
                    hintText:
                        isArabic
                            ? 'اكتب التعديل الذي تريده…'
                            : 'Describe the change you want…',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: isArabic ? 'إرسال' : 'Send',
                onPressed: _isSendingMessage ? null : _sendChatMessage,
                icon:
                    _isSendingMessage
                        ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _resultActions(bool isArabic) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _step = 5;
              _hasUnsavedChanges = true;
            }),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(isArabic ? 'تعديل الإجابات' : 'Edit answers'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  _isSaving || _plan == null || _plan!.days.isEmpty
                      ? null
                      : _savePlan,
              icon: Icon(
                _savedPlanId != null && !_hasUnsavedChanges
                    ? Icons.check_rounded
                    : Icons.bookmark_add_rounded,
              ),
              label: Text(
                _isSaving
                    ? (isArabic ? 'جارٍ الحفظ…' : 'Saving…')
                    : _savedPlanId != null && !_hasUnsavedChanges
                    ? (isArabic ? 'تم الحفظ — خططي' : 'Saved — My Plans')
                    : _savedPlanId != null
                    ? (isArabic ? 'احفظ التعديلات' : 'Save Changes')
                    : (isArabic ? 'احفظ الخطة' : 'Save Plan'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.desertGold,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _savePlan() async {
    final plan = _plan;
    if (plan == null || _isSaving) return;
    setState(() => _isSaving = true);
    final id = _savedPlanId ?? DateTime.now().microsecondsSinceEpoch.toString();
    final visitorClass = plan.visitorClass.name;
    final record = SavedPlanRecord(
      id: id,
      createdAt: DateTime.now(),
      destination: plan.destination,
      budget: plan.budget,
      travelers: plan.travelers,
      daysCount: _tripDays,
      interests: _interests.toList(growable: false),
      pace: _pace.name,
      discovery: _discovery.name,
      visitorClass: visitorClass,
      estimatedLow: plan.estimatedLow,
      estimatedHigh: plan.estimatedHigh,
      usedAi: plan.usedAi,
      days: plan.days
          .map(
            (day) => SavedPlanDay(
              region: day.region,
              placeIds: day.places
                  .map((place) => place.id)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      priceSnapshots: {
        for (final place in plan.days.expand((day) => day.places))
          place.id: JordanPriceCatalog.forPlaceId(place.id).toJson(),
      },
      otherCostsAllowance: plan.otherCostsAllowance,
      additionalRequests: plan.additionalRequests,
      travelDate: plan.travelDate,
      startLocation: plan.startLocation,
      mobilityNeeds: plan.mobilityNeeds,
      accessibilityNeeds: plan.accessibilityNeeds,
      dietaryNeeds: plan.dietaryNeeds,
      explanation: plan.explanation,
      placeReasons: plan.placeReasons,
      chatHistory: _chatMessages
          .map(
            (message) =>
                '${message.fromUser ? 'Traveler' : 'Planner'}: ${message.text}',
          )
          .toList(growable: false),
    );
    try {
      await SavedPlansStore.instance.save(record);
      if (!mounted) return;
      setState(() {
        _savedPlanId = id;
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تم حفظ الخطة على هذا الجهاز. ستجدها في «خططي».'
                : 'Plan saved on this device. Find it in My Plans.',
          ),
          action: SnackBarAction(
            label: _isArabic ? 'افتح' : 'Open',
            onPressed: () => context.push('/my-plans'),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تعذر حفظ الخطة: $error'
                : 'Could not save plan: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _paceLabel(bool ar) => switch (_pace) {
    _TripPace.relaxed => ar ? 'هادئة' : 'Relaxed',
    _TripPace.active => ar ? 'مكثفة' : 'Active',
    _ => ar ? 'متوازنة' : 'Balanced',
  };

  String _discoveryLabel(bool ar) => switch (_discovery) {
    _Discovery.famous => ar ? 'معالم مشهورة' : 'Famous attractions',
    _Discovery.local => ar ? 'جواهر محلية' : 'Local gems',
    _ => ar ? 'مزيج' : 'A mix of places',
  };

  String _interestLabel(bool ar) {
    const labels = <String, (String, String)>{
      'culture': ('Culture & Heritage', 'الثقافة والتراث'),
      'nature': ('Nature', 'الطبيعة'),
      'adventure': ('Adventure', 'المغامرة'),
      'food': ('Local Food', 'الطعام المحلي'),
      'history': ('History', 'التاريخ'),
      'religious': ('Faith & Traditions', 'الدين والتقاليد'),
      'shopping': ('Markets', 'الأسواق'),
    };
    if (_interests.isEmpty) return ar ? 'متنوعة' : 'A broad mix';
    return _interests
        .map((value) => ar ? labels[value]!.$2 : labels[value]!.$1)
        .join(' · ');
  }

  void _useSuggestedBudget(double amount) {
    _budgetController.text = amount.toStringAsFixed(2);
    _buildPlan();
  }

  void _broadenDestination() {
    setState(() => _destination = 'Jordan');
    _buildPlan();
  }
}

class _WizardOption extends StatelessWidget {
  const _WizardOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.horizontal = false,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.desertGold
            : AppColors.sandBeige.withValues(alpha: .75);
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color:
            selected
                ? AppColors.desertGold.withValues(alpha: .12)
                : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: horizontal ? 76 : 70),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: border, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? AppColors.desertGold
                            : AppColors.sandBeige.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: selected ? Colors.white : AppColors.warmBrown,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.desertGold,
                    size: 19,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _PlanResults extends StatelessWidget {
  const _PlanResults({
    required this.plan,
    required this.isArabic,
    required this.money,
    required this.onUseSuggested,
    required this.onBroadenDestination,
  });
  final _TripPlan plan;
  final bool isArabic;
  final String Function(double) money;
  final ValueChanged<double> onUseSuggested;
  final VoidCallback onBroadenDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = JordanPriceCatalog.inexpensiveAmmanMeal;
    final includesAmmanMeals = plan.destination == 'Amman';
    final mealLow =
        includesAmmanMeals
            ? (meal.low ?? 0) * 3 * plan.daysCount * plan.travelers
            : 0.0;
    final mealHigh =
        includesAmmanMeals
            ? (meal.high ?? 0) * 3 * plan.daysCount * plan.travelers
            : 0.0;
    final modeledLow = plan.estimatedLow + plan.otherCostsAllowance + mealLow;
    final modeledHigh =
        plan.estimatedHigh + plan.otherCostsAllowance + mealHigh;
    if (plan.days.isEmpty) {
      return Card(
        color: theme.colorScheme.errorContainer.withValues(alpha: .45),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'لا توجد أماكن تناسب هذه الميزانية'
                    : 'No places fit this budget',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'لم أجد أماكن ذات أسعار موثقة ضمن المبلغ المتاح بعد المخصصات. وسّع المنطقة أو الاهتمامات، أو ارفع الميزانية.'
                    : 'No places with verified prices fit the remaining activity budget. Widen the area or interests, or increase the budget.',
              ),
              const SizedBox(height: 6),
              Text(plan.statusMessage, style: theme.textTheme.bodySmall),
              if (plan.alternatives.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  isArabic
                      ? 'أماكن بديلة لها سعر منشور في مناطق أخرى:'
                      : 'Priced alternatives in other areas:',
                  style: theme.textTheme.titleSmall,
                ),
                for (final place in plan.alternatives.take(3))
                  Text(
                    '• ${isArabic ? place.nameAr : place.name} · ${place.location.split(',').first}',
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onBroadenDestination,
                  icon: const Icon(Icons.public_rounded),
                  label: Text(
                    isArabic
                        ? 'وسّع البحث لكل الأردن'
                        : 'Broaden search to all Jordan',
                  ),
                ),
              ],
              if (plan.suggestedBudget > 0) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => onUseSuggested(plan.suggestedBudget),
                  child: Text(
                    isArabic
                        ? 'جرّب الميزانية المقترحة ${money(plan.suggestedBudget)}'
                        : 'Try suggested budget: ${money(plan.suggestedBudget)}',
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'خطة رحلتك' : 'Your itinerary',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.desertGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'أسعار الأنشطة المعروفة: ${money(plan.estimatedLow)}–${money(plan.estimatedHigh)}'
                            : 'Known activity prices: ${money(plan.estimatedLow)}–${money(plan.estimatedHigh)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'المكونات المقدّرة المتاحة: ${money(modeledLow)}–${money(modeledHigh)}'
                      : 'Modeled components: ${money(modeledLow)}–${money(modeledHigh)}',
                ),
                if (plan.otherCostsAllowance > 0)
                  Text(
                    isArabic
                        ? 'يشمل مخصص نقل وإقامة بقيمة ${money(plan.otherCostsAllowance)} أدخلته أنت.'
                        : 'Includes your own transport/lodging allowance of ${money(plan.otherCostsAllowance)}.',
                  ),
                if (includesAmmanMeals)
                  Text(
                    isArabic
                        ? 'وجبات عمّان: ${money(mealLow)}–${money(mealHigh)}، على افتراض 3 وجبات اقتصادية يوميًا لكل شخص.'
                        : 'Amman meals: ${money(mealLow)}–${money(mealHigh)}, assuming 3 inexpensive meals per person per day.',
                  ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value:
                        plan.budget <= 0
                            ? 0
                            : (modeledHigh / plan.budget)
                                .clamp(0, 1)
                                .toDouble(),
                    backgroundColor: AppColors.sandBeige.withValues(alpha: .5),
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'الإقامة والنقل خارج عمّان غير مسعّرين تلقائيًا. تحقق من التكاليف قبل اعتبار الرحلة ضمن الميزانية.'
                      : 'Lodging and transport outside Amman are not priced automatically. Confirm these costs before treating the trip as within budget.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...plan.days.asMap().entries.map(
          (entry) => _DayCard(
            index: entry.key + 1,
            day: entry.value,
            isArabic: isArabic,
            money: money,
            travelers: plan.travelers,
            reasons: plan.placeReasons,
            visitorClass: plan.visitorClass,
            travelDate: plan.travelDate,
            startLocation: plan.startLocation,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              isArabic
                  ? 'الترتيب حسب المحافظة تقريبي ولا يضمن أقصر مسار. لا تتوفر أزمنة تنقل مباشرة لمعظم المواقع. تحقّق من ساعات العمل والإغلاقات وإمكانية الوصول الموسمية قبل الزيارة.'
                  : 'Governorate grouping is approximate and does not guarantee the shortest route. Live travel times are unavailable for most places. Confirm opening hours, closures, and seasonal access before visiting.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.index,
    required this.day,
    required this.isArabic,
    required this.money,
    required this.travelers,
    required this.reasons,
    required this.visitorClass,
    required this.travelDate,
    required this.startLocation,
  });
  final int index;
  final _PlannerDay day;
  final bool isArabic;
  final String Function(double) money;
  final int travelers;
  final Map<String, String> reasons;
  final VisitorRateClass visitorClass;
  final String travelDate;
  final String startLocation;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(travelDate);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.desertGold,
                  foregroundColor: Colors.white,
                  child: Text('$index'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'اليوم $index · ${day.region}'
                        : 'Day $index · ${day.region}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.desertGold,
                ),
              ],
            ),
            const Divider(height: 22),
            ...day.places.map((place) {
              final price = JordanPriceCatalog.forPlaceId(place.id);
              final low = price.forVisitor(visitorClass) ?? price.low;
              final high = price.high ?? low;
              final visitInfo = JordanVisitInfoCatalog.forPlace(
                place.id,
                visitDate: date,
              );
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.place, color: AppColors.emerald),
                title: Text(isArabic ? place.nameAr : place.name),
                subtitle: Text(
                  low == null || high == null
                      ? (isArabic ? 'السعر غير متحقق' : 'Price not verified')
                      : '${money(low * travelers)}–${money(high * travelers)} · ${price.confidence == PriceConfidence.officialFixed ? (isArabic ? 'سعر رسمي منشور' : 'Published official price') : (isArabic ? 'تقدير سوق منشور' : 'Published market estimate')}',
                ),
                childrenPadding: const EdgeInsetsDirectional.only(
                  start: 40,
                  end: 8,
                  bottom: 12,
                ),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      reasons[place.id] ??
                          (isArabic
                              ? 'اختيرت من بيانات الأماكن المتاحة.'
                              : 'Selected from the available place catalog.'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${price.label} · ${price.unit} · ${price.checkedAt}',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      price.conditions,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (price.sourceUrl.isNotEmpty)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed:
                            () => launchUrl(
                              Uri.parse(price.sourceUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(
                          isArabic
                              ? 'المصدر: ${price.sourceName}'
                              : 'Source: ${price.sourceName}',
                        ),
                      ),
                    ),
                  if (visitInfo != null) ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${isArabic ? 'ساعات الزيارة المنشورة' : 'Published visiting hours'} (${visitInfo.season}): ${visitInfo.hours}',
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${visitInfo.conditions} · ${visitInfo.checkedAt}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          () => launchUrl(
                            Uri.parse(visitInfo.sourceUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: Text(
                        isArabic ? 'مصدر ساعات العمل' : 'Opening-hours source',
                      ),
                    ),
                  ] else
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        isArabic
                            ? 'ساعات العمل والإغلاقات وإمكانية الوصول الموسمية: غير متحققة.'
                            : 'Opening hours, closures, and seasonal accessibility: not verified.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      isArabic
                          ? 'زمن الطريق من $startLocation غير متحقق.'
                          : 'Route time from $startLocation is not verified.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.sandBeige.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isArabic
                    ? 'إيقاع مقترح: زيارات صباحية · استراحة/وجبة منتصف اليوم · زيارات بعد الظهر. المواعيد الفعلية غير متحققة.'
                    : 'Suggested rhythm: morning visits · midday meal/rest break · afternoon visits. Exact opening and travel times are not verified.',
              ),
            ),
            Text(
              isArabic
                  ? 'اقتراح اليوم مبني على ${day.places.length} أماكن قريبة إداريًا من بعضها.'
                  : 'Grouped into ${day.places.length} stops in the same governorate.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
