import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatEntry> _messages = [];
  int _questionIndex = 0;
  bool _isTyping = false;
  bool _itineraryGenerated = false;
  final Map<String, String> _answers = {};

  static const _questionsEn = [
    'How many days is your trip?',
    'What is your budget range?',
    'What interests you most? (heritage, adventure, food)',
    'Who are you traveling with?',
  ];

  static const _questionsAr = [
    'كم يوماً ستستغرق رحلتك؟',
    'ما هو نطاق ميزانيتك؟',
    'ما الذي يهمك أكثر؟ (تراث، مغامرة، طعام)',
    'مع من تسافر؟',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConversation());
  }

  void _startConversation() {
    final isArabic = context.read<AppProvider>().isArabic;
    _addBotMessage(
      isArabic
          ? 'مرحباً! أنا مرشدك الذكي في توراثي. دعني أصمم لك رحلة مثالية في الأردن. 🌟'
          : 'Hello! I\'m your TouRathi AI guide. Let me craft your perfect Jordan adventure. 🌟',
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _askNextQuestion();
    });
  }

  void _askNextQuestion() {
    final isArabic = context.read<AppProvider>().isArabic;
    if (_questionIndex >= _questionsEn.length) {
      _generateItinerary();
      return;
    }
    final question = isArabic
        ? _questionsAr[_questionIndex]
        : _questionsEn[_questionIndex];
    _addBotMessage(question);
  }

  void _addBotMessage(String text) {
    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatEntry(text: text, isBot: true));
      });
      _scrollToBottom();
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatEntry(text: text, isBot: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty ||
        _isTyping ||
        _itineraryGenerated ||
        _questionIndex >= _questionsEn.length) {
      return;
    }

    _addUserMessage(text);
    _inputController.clear();

    final keys = ['days', 'budget', 'interests', 'companions'];
    _answers[keys[_questionIndex]] = text;
    _questionIndex++;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _askNextQuestion();
    });
  }

  void _generateItinerary() {
    final isArabic = context.read<AppProvider>().isArabic;
    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _itineraryGenerated = true;
        _messages.add(
          _ChatEntry(
            text: isArabic
                ? 'رائع! إليك مسارك المخصص:'
                : 'Wonderful! Here\'s your personalized itinerary:',
            isBot: true,
            isItinerary: true,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkCharcoal, AppColors.darkSurface]
                : [
                    AppColors.ivoryWhite,
                    AppColors.sandBeige.withValues(alpha: 0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _LuxuryHeader(isArabic: isArabic),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    isArabic
                        ? 'نسخة تجريبية: النتائج المعروضة ليست مولدة من خدمة AI ولا تؤكد الأسعار أو المواعيد أو المسارات.'
                        : 'Prototype: results are not generated by an AI service and do not verify prices, opening hours, or routes.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _TypingIndicator(isArabic: isArabic);
                    }
                    final msg = _messages[index];
                    if (msg.isItinerary) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChatBubble(entry: msg, isArabic: isArabic),
                          _ItineraryCard(isArabic: isArabic, answers: _answers)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.1, end: 0),
                          _BudgetSummary(
                            isArabic: isArabic,
                          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                        ],
                      );
                    }
                    return _ChatBubble(entry: msg, isArabic: isArabic)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: msg.isBot ? -0.05 : 0.05, end: 0);
                  },
                ),
              ),
              if (!_itineraryGenerated)
                _InputBar(
                  controller: _inputController,
                  isArabic: isArabic,
                  onSend: _sendMessage,
                ),
              if (_itineraryGenerated)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GradientButton(
                    label: isArabic ? 'حفظ المسار' : 'Save Itinerary',
                    icon: Icons.bookmark_add_outlined,
                    width: double.infinity,
                    onPressed: () => context.pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEntry {
  const _ChatEntry({
    required this.text,
    required this.isBot,
    this.isItinerary = false,
  });

  final String text;
  final bool isBot;
  final bool isItinerary;
}

class _LuxuryHeader extends StatelessWidget {
  const _LuxuryHeader({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
      decoration: BoxDecoration(
        gradient: AppColors.aiGlow,
        boxShadow: [
          BoxShadow(
            color: AppColors.royalBlue.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('planMyDay', isArabic),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isArabic
                      ? 'مرشدك الذكي للسياحة'
                      : 'Your AI tourism concierge',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.entry, required this.isArabic});

  final _ChatEntry entry;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final isBot = entry.isBot;

    return Align(
      alignment: isBot
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isBot
              ? LinearGradient(
                  colors: [
                    AppColors.darkCard.withValues(alpha: 0.9),
                    AppColors.warmBrown.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isBot ? null : AppColors.desertGold,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusMedium),
            topRight: const Radius.circular(AppTheme.radiusMedium),
            bottomLeft: Radius.circular(isBot ? 4 : AppTheme.radiusMedium),
            bottomRight: Radius.circular(isBot ? AppTheme.radiusMedium : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmBrown.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          entry.text,
          style: AppTypography.textStyle(
            isArabic: isArabic,
            fontSize: 14,
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.desertGold,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(delay: (200 * i).ms, duration: 400.ms)
                .then()
                .fadeOut(duration: 400.ms);
          }),
        ),
      ),
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.isArabic, required this.answers});

  final bool isArabic;
  final Map<String, String> answers;

  @override
  Widget build(BuildContext context) {
    final days = [
      _DayPlan(
        day: isArabic ? 'اليوم 1' : 'Day 1',
        title: isArabic ? 'عمان التاريخية' : 'Historic Amman',
        activities: isArabic
            ? ['قلعة عمان', 'المدرج الروماني', 'جبل اللويبدة']
            : ['Amman Citadel', 'Roman Theatre', 'Jabal Al-Weibdeh'],
        icon: Icons.location_city,
      ),
      _DayPlan(
        day: isArabic ? 'اليوم 2' : 'Day 2',
        title: isArabic ? 'البتراء الوردية' : 'Rose City Petra',
        activities: isArabic
            ? ['الخزنة', 'الدير', 'وادي السيق']
            : ['The Treasury', 'The Monastery', 'Siq Canyon'],
        icon: Icons.account_balance,
      ),
      _DayPlan(
        day: isArabic ? 'اليوم 3' : 'Day 3',
        title: isArabic ? 'وادي رم الصحراوي' : 'Wadi Rum Desert',
        activities: isArabic
            ? ['جولة جيب', 'تخييم بدوي', 'مراقبة النجوم']
            : ['Jeep tour', 'Bedouin camp', 'Stargazing'],
        icon: Icons.landscape,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        border: Border.all(color: AppColors.desertGold.withValues(alpha: 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppColors.desertGold),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'مسارك اليومي' : 'Your Day-by-Day Plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              return _DayPlanTile(day: day, isArabic: isArabic)
                  .animate()
                  .fadeIn(delay: (150 * index).ms, duration: 400.ms)
                  .slideX(begin: 0.05, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}

class _DayPlan {
  const _DayPlan({
    required this.day,
    required this.title,
    required this.activities,
    required this.icon,
  });

  final String day;
  final String title;
  final List<String> activities;
  final IconData icon;
}

class _DayPlanTile extends StatelessWidget {
  const _DayPlanTile({required this.day, required this.isArabic});

  final _DayPlan day;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sandBeige.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppColors.sandBeige.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.goldShimmer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(day.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.day} · ${day.title}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...day.activities.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            a,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final items = isArabic
        ? [
            ('الإقامة', '180 دينار'),
            ('المواصلات', '95 دينار'),
            ('الأنشطة', '120 دينار'),
            ('الطعام', '75 دينار'),
          ]
        : [
            ('Accommodation', '180 JOD'),
            ('Transport', '95 JOD'),
            ('Activities', '120 JOD'),
            ('Food', '75 JOD'),
          ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          AppColors.desertGold.withValues(alpha: 0.15),
          AppColors.sandBeige.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'ملخص الميزانية' : 'Budget Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.desertGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isArabic ? '470 دينار' : '470 JOD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.$1, style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    item.$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.desertGold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isArabic,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isArabic;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: isArabic ? 'اكتب ردك...' : 'Type your answer...',
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.desertGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.desertGold.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
