import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';
import 'feature_store.dart';

const _groups = <_TravelGroupData>[
  _TravelGroupData(
    id: 'petra-night-photographers',
    title: 'Petra Night Photographers',
    titleAr: 'مصورّو البتراء ليلاً',
    place: 'Petra',
    placeAr: 'البتراء',
    detail: 'Golden-hour walks, night-sky tips, and photo meetups.',
    detailAr: 'جولات الغروب، نصائح تصوير السماء، ولقاءات المصورين.',
    people: 248,
    date: 'Fri · 6:30 PM',
    dateAr: 'الجمعة · ٦:٣٠ مساءً',
    image: 'assets/images/home/petra.jpg',
  ),
  _TravelGroupData(
    id: 'wadi-rum-hikers',
    title: 'Wadi Rum Hikers',
    titleAr: 'مستكشفو وادي رم',
    place: 'Wadi Rum',
    placeAr: 'وادي رم',
    detail: 'Small-group desert treks led by local guides.',
    detailAr: 'مسارات صحراوية لمجموعات صغيرة مع أدلاء محليين.',
    people: 186,
    date: 'Sat · 7:00 AM',
    dateAr: 'السبت · ٧:٠٠ صباحاً',
    image: 'assets/images/home/wadi_rum.jpg',
  ),
  _TravelGroupData(
    id: 'north-jordan-nature',
    title: 'North Jordan Nature',
    titleAr: 'طبيعة شمال الأردن',
    place: 'Ajloun',
    placeAr: 'عجلون',
    detail: 'Forest trails, local food, and slow weekends outdoors.',
    detailAr: 'دروب الغابات، الطعام المحلي، وعطلات هادئة في الطبيعة.',
    people: 94,
    date: 'Sun · 9:00 AM',
    dateAr: 'الأحد · ٩:٠٠ صباحاً',
    image: 'assets/images/home/jerash.jpg',
  ),
];

const _activities = <_ActivityData>[
  _ActivityData(
    id: 'petra-by-night',
    title: 'Petra by Night Walk',
    titleAr: 'مسيرة البتراء ليلاً',
    place: 'Petra Visitor Centre',
    placeAr: 'مركز زوار البتراء',
    date: 'Thu · 8:30 PM',
    dateAr: 'الخميس · ٨:٣٠ مساءً',
    price: '17 JOD',
    image: 'assets/images/home/petra.jpg',
    description:
        'Walk the Siq by candlelight and experience the Treasury after dark.',
    descriptionAr: 'اعبر السيق على ضوء الشموع وشاهد الخزنة بعد الغروب.',
  ),
  _ActivityData(
    id: 'wadi-rum-sunrise',
    title: 'Wadi Rum Sunrise Jeep Tour',
    titleAr: 'جولة شروق الشمس في وادي رم',
    place: 'Wadi Rum',
    placeAr: 'وادي رم',
    date: 'Daily · 5:00 AM',
    dateAr: 'يومياً · ٥:٠٠ صباحاً',
    price: '35 JOD',
    image: 'assets/images/home/wadi_rum.jpg',
    description: 'See sandstone valleys wake up with a local Bedouin guide.',
    descriptionAr: 'شاهد أودية الحجر الرملي تستيقظ برفقة دليل بدوي محلي.',
  ),
  _ActivityData(
    id: 'jerash-heritage',
    title: 'Jerash Heritage Walk',
    titleAr: 'جولة تراثية في جرش',
    place: 'Jerash',
    placeAr: 'جرش',
    date: 'Sat · 10:00 AM',
    dateAr: 'السبت · ١٠:٠٠ صباحاً',
    price: '12 JOD',
    image: 'assets/images/home/jerash.jpg',
    description:
        'Explore the colonnaded streets and stories of the Roman city.',
    descriptionAr: 'اكتشف الشوارع ذات الأعمدة وحكايات المدينة الرومانية.',
  ),
];

const _products = <_ProductData>[
  _ProductData(
    'madaba-mosaic',
    'Madaba Mosaic Coaster Set',
    'طقم قواعد فسيفساء من مادبا',
    'Madaba',
    'مادبا',
    '18 JOD',
    'assets/images/home/petra.jpg',
  ),
  _ProductData(
    'salt-soap',
    'Salt Olive Oil Soap',
    'صابون زيت الزيتون من السلط',
    'As-Salt',
    'السلط',
    '6 JOD',
    'assets/images/home/jerash.jpg',
  ),
  _ProductData(
    'wadi-scarf',
    'Wadi Rum Woven Scarf',
    'وشاح منسوج من وادي رم',
    'Wadi Rum',
    'وادي رم',
    '24 JOD',
    'assets/images/home/wadi_rum.jpg',
  ),
  _ProductData(
    'dead-sea-salt',
    'Dead Sea Mineral Soak',
    'أملاح البحر الميت المعدنية',
    'Dead Sea',
    'البحر الميت',
    '12 JOD',
    'assets/images/home/dead_sea.jpg',
  ),
];

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'الأنشطة والتجارب' : 'Activities & experiences',
      subtitle:
          ar
              ? 'تجارب محلية تختصر لك حكاية المكان'
              : 'Local experiences that bring each place to life',
      children: [
        _FeatureHero(
          icon: Icons.local_activity_rounded,
          eyebrow: ar ? 'اكتشف الأردن' : 'DISCOVER JORDAN',
          title: ar ? 'خطط ليوم لا يُنسى' : 'Make a day of it',
          caption:
              ar
                  ? 'اختر تجربة تناسب إيقاع رحلتك.'
                  : 'Find a guided experience that fits your pace.',
          actionLabel: ar ? 'خطط مع الذكاء الاصطناعي' : 'Plan with AI',
          onAction: () => context.push('/ai-planner'),
        ),
        const SizedBox(height: 22),
        _SectionHeading(
          title: ar ? 'قريباً منك' : 'Coming up in Jordan',
          action: ar ? 'عرض الكل' : 'View all',
        ),
        for (final activity in _activities)
          _ActivityCard(
            activity: activity,
            ar: ar,
            onTap: () => context.push('/activity/${activity.id}'),
          ),
      ],
    );
  }
}

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key, required this.activityId});
  final String activityId;

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final activity = _activities.firstWhere(
      (item) => item.id == activityId,
      orElse: () => _activities.first,
    );
    return _FeaturePage(
      title: ar ? activity.titleAr : activity.title,
      children: [
        _LocalPhoto(path: activity.image, height: 270, radius: 26),
        const SizedBox(height: 18),
        _FeaturePill(
          icon: Icons.place_outlined,
          text: ar ? activity.placeAr : activity.place,
        ),
        const SizedBox(height: 12),
        Text(
          ar ? activity.descriptionAr : activity.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        _InfoRow(
          icon: Icons.calendar_month_outlined,
          label: ar ? 'الموعد' : 'When',
          value: ar ? activity.dateAr : activity.date,
        ),
        _InfoRow(
          icon: Icons.payments_outlined,
          label: ar ? 'السعر للفرد' : 'Price per person',
          value: activity.price,
        ),
        const SizedBox(height: 22),
        _PrimaryAction(
          label: ar ? 'احجز تجربة تجريبية' : 'Book a demo ticket',
          icon: Icons.confirmation_number_outlined,
          onPressed: () async {
            await ExtrasStore.saveTicket({
              'id': '${activity.id}-${DateTime.now().millisecondsSinceEpoch}',
              'title': activity.title,
              'titleAr': activity.titleAr,
              'place': activity.place,
              'placeAr': activity.placeAr,
              'date': activity.date,
              'dateAr': activity.dateAr,
              'price': activity.price,
            });
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ar
                        ? 'أُضيفت التذكرة التجريبية إلى تذاكري'
                        : 'Demo ticket added to My tickets',
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Text(
          ar
              ? 'الحجز تجريبي ومحفوظ على هذا الجهاز؛ الدفع الإلكتروني غير موصول.'
              : 'Demo booking is saved on this device; online payments are not connected.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late Future<List<Map<String, String>>> _tickets = ExtrasStore.loadTickets();
  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'تذاكري' : 'My tickets',
      subtitle:
          ar
              ? 'كل حجوزاتك القادمة في مكان واحد'
              : 'Your upcoming experiences, all together',
      children: [
        FutureBuilder<List<Map<String, String>>>(
          future: _tickets,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) {
              return _EmptyFeature(
                icon: Icons.confirmation_number_outlined,
                title: ar ? 'لا توجد تذاكر بعد' : 'No tickets yet',
                detail:
                    ar
                        ? 'احجز تجربة من الأنشطة وستظهر هنا.'
                        : 'Book an experience from Activities and it will appear here.',
                action: ar ? 'اكتشف الأنشطة' : 'Explore activities',
                onTap: () => context.push('/activities'),
              );
            }
            return Column(
              children: [
                for (final ticket in tickets)
                  _TicketCard(ticket: ticket, ar: ar),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _tickets = ExtrasStore.loadTickets()),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(ar ? 'تحديث التذاكر' : 'Refresh tickets'),
        ),
      ],
    );
  }
}

class TravelGroupsScreen extends StatefulWidget {
  const TravelGroupsScreen({super.key});
  @override
  State<TravelGroupsScreen> createState() => _TravelGroupsScreenState();
}

class _TravelGroupsScreenState extends State<TravelGroupsScreen> {
  final Set<String> _joined = {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final group in _groups) {
      if (await ExtrasStore.isJoined(group.id)) _joined.add(group.id);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'مجموعات السفر' : 'Travel groups',
      subtitle:
          ar
              ? 'اكتشف الأردن برفقة أشخاص يشاركونك الاهتمام'
              : 'Explore Jordan with people who share your interests',
      children: [
        _FeatureHero(
          icon: Icons.groups_rounded,
          eyebrow: ar ? 'مجتمع تراثي' : 'TOURATHI COMMUNITY',
          title: ar ? 'الرحلة أجمل مع رفقة' : 'Better journeys, together',
          caption:
              ar
                  ? 'انضم إلى مجموعات محلية موثوقة وابدأ التخطيط.'
                  : 'Meet local explorers and plan your next outing.',
          actionLabel: ar ? 'خطط لمجموعة' : 'Plan for a group',
          onAction: () => context.push('/ai-group-planner'),
        ),
        const SizedBox(height: 20),
        for (final group in _groups)
          _GroupCard(
            group: group,
            ar: ar,
            joined: _joined.contains(group.id),
            onOpen: () => context.push('/community/${group.id}'),
            onJoin: () async {
              final join = !_joined.contains(group.id);
              await ExtrasStore.setJoined(group.id, join);
              if (mounted) {
                setState(
                  () => join ? _joined.add(group.id) : _joined.remove(group.id),
                );
              }
            },
          ),
      ],
    );
  }
}

class TravelGroupDetailsScreen extends StatefulWidget {
  const TravelGroupDetailsScreen({super.key, required this.groupId});
  final String groupId;
  @override
  State<TravelGroupDetailsScreen> createState() =>
      _TravelGroupDetailsScreenState();
}

class _TravelGroupDetailsScreenState extends State<TravelGroupDetailsScreen> {
  bool _joined = false;
  @override
  void initState() {
    super.initState();
    ExtrasStore.isJoined(widget.groupId).then((value) {
      if (mounted) setState(() => _joined = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final group = _groups.firstWhere(
      (item) => item.id == widget.groupId,
      orElse: () => _groups.first,
    );
    return _FeaturePage(
      title: ar ? group.titleAr : group.title,
      children: [
        _LocalPhoto(path: group.image, height: 240, radius: 26),
        const SizedBox(height: 16),
        _FeaturePill(
          icon: Icons.place_outlined,
          text: ar ? group.placeAr : group.place,
        ),
        const SizedBox(height: 12),
        Text(
          ar ? group.detailAr : group.detail,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        _InfoRow(
          icon: Icons.people_outline_rounded,
          label: ar ? 'المستكشفون' : 'Explorers',
          value: '${group.people}',
        ),
        _InfoRow(
          icon: Icons.event_outlined,
          label: ar ? 'اللقاء القادم' : 'Next meetup',
          value: ar ? group.dateAr : group.date,
        ),
        const SizedBox(height: 14),
        _PrimaryAction(
          label:
              _joined
                  ? (ar ? 'تم الانضمام' : 'Joined')
                  : (ar ? 'انضم للمجموعة' : 'Join group'),
          icon: _joined ? Icons.check_rounded : Icons.group_add_rounded,
          onPressed: () async {
            final next = !_joined;
            await ExtrasStore.setJoined(group.id, next);
            if (mounted) setState(() => _joined = next);
          },
        ),
        const SizedBox(height: 10),
        _ActionCard(
          icon: Icons.forum_outlined,
          title: ar ? 'محادثة المجموعة' : 'Group conversation',
          subtitle: ar ? 'شارك التفاصيل مع الأعضاء' : 'Coordinate with members',
          onTap: () => context.push('/group-chat/${group.id}'),
        ),
        _ActionCard(
          icon: Icons.auto_awesome_rounded,
          title: ar ? 'خطط الرحلة معاً' : 'Plan the trip together',
          subtitle:
              ar
                  ? 'أنشئ تصوراً يناسب المجموعة'
                  : 'Build an itinerary for everyone',
          onTap: () => context.push('/ai-group-planner'),
        ),
        Text(
          ar
              ? 'هذه مجموعة تجريبية؛ الانضمام والرسائل محفوظة محلياً على هذا الجهاز.'
              : 'Demo community: membership and messages are stored locally on this device.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.groupId});
  final String groupId;
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late Future<List<Map<String, String>>> _messages;
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    final group = _groups.firstWhere(
      (item) => item.id == widget.groupId,
      orElse: () => _groups.first,
    );
    _messages = ExtrasStore.loadMessages(widget.groupId, [
      {
        'sender': 'Layla',
        'text': 'I can bring a tripod and spare batteries.',
        'time': '6:42 PM',
        'mine': 'false',
      },
      {
        'sender': 'Omar',
        'text': 'The trail opens early. Let’s meet by the visitor centre.',
        'time': '6:48 PM',
        'mine': 'false',
      },
      {
        'sender': group.title,
        'text': 'Welcome! Share your questions here before the meetup.',
        'time': '6:50 PM',
        'mine': 'false',
      },
    ]).then((data) {
      _ready = true;
      return data;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final time = TimeOfDay.now().format(context);
    final messages = await _messages;
    messages.add({
      'sender': 'You',
      'text': value,
      'time': time,
      'mine': 'true',
    });
    await ExtrasStore.saveMessages(widget.groupId, messages);
    _controller.clear();
    if (mounted) setState(() => _messages = Future.value(messages));
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final group = _groups.firstWhere(
      (item) => item.id == widget.groupId,
      orElse: () => _groups.first,
    );
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ar ? group.titleAr : group.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              ar ? '${group.people} مستكشف' : '${group.people} explorers',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _messages,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = message['mine'] == 'true';
                    return Align(
                      alignment:
                          mine
                              ? AlignmentDirectional.centerEnd
                              : AlignmentDirectional.centerStart,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .78,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color:
                              mine
                                  ? AppColors.warmBrown
                                  : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!mine)
                              Text(
                                message['sender'] ?? '',
                                style: TextStyle(
                                  color: AppColors.desertGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            Text(
                              message['text'] ?? '',
                              style: TextStyle(
                                color: mine ? Colors.white : null,
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                message['time'] ?? '',
                                style: TextStyle(
                                  color:
                                      mine
                                          ? Colors.white70
                                          : Theme.of(context).hintColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText:
                            ar ? 'اكتب رسالة للمجموعة…' : 'Message the group…',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _ready ? _send : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              ar
                  ? 'محادثة تجريبية محفوظة على هذا الجهاز'
                  : 'Demo chat · saved on this device',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class AiGroupPlannerScreen extends StatefulWidget {
  const AiGroupPlannerScreen({super.key});
  @override
  State<AiGroupPlannerScreen> createState() => _AiGroupPlannerScreenState();
}

class _AiGroupPlannerScreenState extends State<AiGroupPlannerScreen> {
  final _form = GlobalKey<FormState>();
  final _destination = TextEditingController(text: 'Petra & Wadi Rum');
  final _people = TextEditingController(text: '6');
  final _days = TextEditingController(text: '3');
  bool _generated = false;
  @override
  void dispose() {
    _destination.dispose();
    _people.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'مخطط الرحلات الجماعية' : 'AI group planner',
      subtitle:
          ar
              ? 'خطط تناسب وقت المجموعة وميزانيتها'
              : 'Bring your group’s timing and budget together',
      children: [
        _FeatureHero(
          icon: Icons.auto_awesome_rounded,
          eyebrow: ar ? 'تخطيط جماعي' : 'GROUP TRIP DESIGN',
          title: ar ? 'خطة واحدة تناسب الجميع' : 'One plan for the whole crew',
          caption:
              ar
                  ? 'ابدأ بتفاصيل بسيطة وعدّل النتيجة لاحقاً.'
                  : 'Start with a few details and refine the itinerary together.',
          actionLabel: ar ? 'افتح المخطط الكامل' : 'Open full trip planner',
          onAction: () => context.push('/ai-planner'),
        ),
        const SizedBox(height: 18),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _destination,
                decoration: InputDecoration(
                  labelText: ar ? 'الوجهات' : 'Destinations',
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? (ar ? 'اكتب الوجهة' : 'Enter a destination')
                            : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _people,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ar ? 'عدد المسافرين' : 'Group size',
                        prefixIcon: const Icon(Icons.groups_outlined),
                      ),
                      validator: (value) => _positive(value, ar),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _days,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ar ? 'عدد الأيام' : 'Days',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (value) => _positive(value, ar),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PrimaryAction(
                label: ar ? 'أنشئ خطة المجموعة' : 'Create group itinerary',
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    setState(() => _generated = true);
                  }
                },
              ),
            ],
          ),
        ),
        if (_generated) ...[
          const SizedBox(height: 20),
          _FeaturePill(
            icon: Icons.auto_awesome,
            text:
                ar
                    ? 'اقتراح تجريبي من بيانات محلية'
                    : 'Demo suggestion from the local catalogue',
          ),
          _PlanDayCard(
            day: ar ? 'اليوم الأول' : 'Day one',
            title: ar ? 'اكتشف البتراء' : 'Discover Petra',
            places:
                ar
                    ? 'السيق · الخزنة · مسار الدير'
                    : 'The Siq · Treasury · Monastery trail',
          ),
          _PlanDayCard(
            day: ar ? 'اليوم الثاني' : 'Day two',
            title: ar ? 'إلى وادي رم' : 'Into Wadi Rum',
            places:
                ar
                    ? 'جولة جيب · شاي بدوي · مراقبة النجوم'
                    : 'Jeep route · Bedouin tea · Stargazing',
          ),
          _PlanDayCard(
            day: ar ? 'اليوم الثالث' : 'Day three',
            title:
                ar
                    ? 'وقت هادئ قرب البحر الميت'
                    : 'Slow morning by the Dead Sea',
            places:
                ar
                    ? 'إطلالة الوادي · استراحة محلية'
                    : 'Valley viewpoint · Local lunch',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/ai-planner'),
            icon: const Icon(Icons.tune_rounded),
            label: Text(
              ar ? 'خصّص الخطة بالتفصيل' : 'Customize in trip planner',
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          ar
              ? 'هذا تصور تجريبي محلي؛ لم يتم استدعاء خدمة AI خارجية.'
              : 'This is a local demo itinerary; no external AI service was called.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String? _positive(String? value, bool ar) =>
      int.tryParse(value ?? '') == null || int.parse(value!) < 1
          ? (ar ? 'أدخل رقماً أكبر من صفر' : 'Enter a number above zero')
          : null;
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _cart = 0;
  @override
  void initState() {
    super.initState();
    ExtrasStore.loadCartCount().then((v) {
      if (mounted) setState(() => _cart = v);
    });
  }

  void _openCart(bool ar) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'سلة التسوق' : 'Your cart',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.warmBrown,
                  ),
                  title: Text(ar ? 'منتجات محلية' : 'Local finds'),
                  subtitle: Text(
                    ar ? '$_cart قطع في السلة' : '$_cart item(s) in your cart',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _cart == 0
                            ? null
                            : () {
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ar
                                        ? 'الدفع غير موصول في النسخة التجريبية.'
                                        : 'Checkout is not connected in this demo.',
                                  ),
                                ),
                              );
                            },
                    child: Text(
                      ar ? 'متابعة تجريبية' : 'Continue demo checkout',
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'سوق الأردن' : 'Jordan marketplace',
      subtitle:
          ar
              ? 'منتجات وحرف من صُنّاع محليين'
              : 'Handmade finds from local makers',
      children: [
        _FeatureHero(
          icon: Icons.storefront_rounded,
          eyebrow: ar ? 'تسوّق محلياً' : 'SHOP LOCAL',
          title:
              ar ? 'حكاية أردنية تأخذها معك' : 'Bring a piece of Jordan home',
          caption:
              ar
                  ? 'اكتشف هدايا تحمل روح المكان.'
                  : 'Discover thoughtful souvenirs with a local story.',
          actionLabel: ar ? 'سلتك ($_cart)' : 'Cart ($_cart)',
          onAction: () => _openCart(ar),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemBuilder: (context, index) {
                final item = _products[index];
                return _ProductCard(
                  product: item,
                  ar: ar,
                  onAdd: () async {
                    final count = await ExtrasStore.addCartItem();
                    if (mounted) setState(() => _cart = count);
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          ar
              ? 'السلة محلية للتجربة؛ الدفع والطلب غير موصولين.'
              : 'The cart is local demo state; checkout and fulfillment are not connected.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class JordanPassportScreen extends StatefulWidget {
  const JordanPassportScreen({super.key});
  @override
  State<JordanPassportScreen> createState() => _JordanPassportScreenState();
}

class _JordanPassportScreenState extends State<JordanPassportScreen> {
  Set<String> _stamps = {};
  @override
  void initState() {
    super.initState();
    ExtrasStore.loadStamps().then((v) {
      if (mounted) setState(() => _stamps = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final places = JordanPlaceSeed.places.take(8).toList();
    return _FeaturePage(
      title: ar ? 'جواز الأردن' : 'Jordan passport',
      subtitle:
          ar
              ? 'اجمع أختاماً رقمية من الأماكن التي تكتشفها'
              : 'Collect a digital stamp for every place you explore',
      children: [
        _FeatureHero(
          icon: Icons.confirmation_num_rounded,
          eyebrow: ar ? 'جوازك الرقمي' : 'YOUR DIGITAL PASSPORT',
          title:
              ar
                  ? '${_stamps.length} من ${places.length} أختام'
                  : '${_stamps.length} of ${places.length} stamps',
          caption:
              ar
                  ? 'ابدأ من وجهتك القادمة وافتح ذكرى جديدة.'
                  : 'Start at your next destination and unlock a new memory.',
          actionLabel: ar ? 'استكشف الأماكن' : 'Explore places',
          onAction: () => context.go('/main'),
        ),
        const SizedBox(height: 16),
        for (final place in places)
          _PassportStampRow(
            place: place,
            ar: ar,
            unlocked: _stamps.contains(place.id),
            onTap: () async {
              await ExtrasStore.addStamp(place.id);
              if (mounted) setState(() => _stamps.add(place.id));
            },
          ),
        const SizedBox(height: 8),
        Text(
          ar
              ? 'الأختام تجريبية ومحفوظة على هذا الجهاز.'
              : 'Demo stamps are saved on this device.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class EmergencySafetyScreen extends StatelessWidget {
  const EmergencySafetyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    return _FeaturePage(
      title: ar ? 'السلامة والطوارئ' : 'Emergency & safety',
      subtitle:
          ar
              ? 'أرقام مساعدة أساسية أثناء رحلتك'
              : 'Key contacts while you travel in Jordan',
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9D3B31), Color(0xFF6E2724)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(height: 20),
              Text(
                ar ? 'هل تحتاج مساعدة عاجلة؟' : 'Need urgent help?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ar
                    ? 'اتصل برقم الطوارئ الموحد في الأردن.'
                    : 'Call Jordan’s unified emergency number.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF812F2A),
                  ),
                  onPressed: () => _call(context, '911'),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('911'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeading(title: ar ? 'جهات الاتصال' : 'Useful contacts'),
        _EmergencyContact(
          title: ar ? 'الإسعاف' : 'Ambulance',
          number: '193',
          icon: Icons.medical_services_outlined,
          onTap: () => _call(context, '193'),
        ),
        _EmergencyContact(
          title: ar ? 'الدفاع المدني' : 'Civil defense',
          number: '199',
          icon: Icons.local_fire_department_outlined,
          onTap: () => _call(context, '199'),
        ),
        _EmergencyContact(
          title: ar ? 'الشرطة السياحية' : 'Tourist police',
          number: '+962 79 550 5755',
          icon: Icons.support_agent_rounded,
          onTap: () => _call(context, '+962795505755'),
        ),
        const SizedBox(height: 8),
        Text(
          ar
              ? 'الاتصال يفتح تطبيق الهاتف بعد ضغطك على الرقم. لا تتم مشاركة موقعك تلقائياً.'
              : 'Tapping a number opens your phone app. Your location is not shared automatically.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().isArabic
                ? 'تعذر فتح تطبيق الهاتف'
                : 'Could not open the phone app',
          ),
        ),
      );
    }
  }
}

class TimeTravelerScreen extends StatefulWidget {
  const TimeTravelerScreen({super.key});
  @override
  State<TimeTravelerScreen> createState() => _TimeTravelerScreenState();
}

class _TimeTravelerScreenState extends State<TimeTravelerScreen> {
  String _place = 'Petra';
  String _style = 'Nabataean era';
  bool _generated = false;
  final _styles = const ['Nabataean era', 'Roman era', 'Desert at dusk'];
  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final options =
        ar
            ? const ['العصر النبطي', 'العصر الروماني', 'الصحراء عند الغروب']
            : _styles;
    final selectedLabel = ar ? options[_styles.indexOf(_style)] : _style;
    final photo =
        _place == 'Wadi Rum'
            ? 'assets/images/home/wadi_rum.jpg'
            : _place == 'Jerash'
            ? 'assets/images/home/jerash.jpg'
            : 'assets/images/home/petra.jpg';
    return _FeaturePage(
      title: ar ? 'مسافر عبر الزمن' : 'Time traveler AI',
      subtitle:
          ar
              ? 'تخيّل ماضي المواقع الأردنية بصرياً'
              : 'Imagine how Jordan’s landmarks may have looked',
      children: [
        _LocalPhoto(path: photo, height: 220, radius: 25),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _place,
          decoration: InputDecoration(
            labelText: ar ? 'اختر المكان' : 'Choose a place',
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          items:
              ['Petra', 'Wadi Rum', 'Jerash']
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        ar
                            ? {
                              'Petra': 'البتراء',
                              'Wadi Rum': 'وادي رم',
                              'Jerash': 'جرش',
                            }[p]!
                            : p,
                      ),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() {
                _place = value ?? 'Petra';
                _generated = false;
              }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _style,
          decoration: InputDecoration(
            labelText: ar ? 'الفترة أو الأجواء' : 'Era or atmosphere',
            prefixIcon: const Icon(Icons.history_rounded),
          ),
          items:
              _styles
                  .asMap()
                  .entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.value,
                      child: Text(options[e.key]),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() {
                _style = value ?? _styles.first;
                _generated = false;
              }),
        ),
        const SizedBox(height: 14),
        _PrimaryAction(
          label: ar ? 'أنشئ تصوراً' : 'Generate a preview',
          icon: Icons.auto_awesome_rounded,
          onPressed: () => setState(() => _generated = true),
        ),
        if (_generated) ...[
          const SizedBox(height: 16),
          _FeaturePill(
            icon: Icons.auto_awesome_rounded,
            text: ar ? 'معاينة محلية تجريبية' : 'Local demo preview',
          ),
          Text(
            ar
                ? 'تم اختيار $selectedLabel في ${_place == 'Petra'
                    ? 'البتراء'
                    : _place == 'Jerash'
                    ? 'جرش'
                    : 'وادي رم'}.'
                : 'Preview prepared for $_place · $selectedLabel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            ar
                ? 'لا توجد خدمة توليد صور AI موصولة؛ الصورة المعروضة من ملفات المشروع.'
                : 'No AI image-generation service is connected; this preview uses an existing project photo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class ArExperienceScreen extends StatefulWidget {
  const ArExperienceScreen({super.key});
  @override
  State<ArExperienceScreen> createState() => _ArExperienceScreenState();
}

class _ArExperienceScreenState extends State<ArExperienceScreen> {
  double _era = 0.65;
  String _place = 'Petra';
  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final label =
        _era < .35
            ? (ar ? 'العصور القديمة' : 'Ancient period')
            : _era < .7
            ? (ar ? 'الفترة النبطية' : 'Nabataean period')
            : (ar ? 'اليوم' : 'Today');
    final image =
        _place == 'Wadi Rum'
            ? 'assets/images/home/wadi_rum.jpg'
            : _place == 'Jerash'
            ? 'assets/images/home/jerash.jpg'
            : 'assets/images/home/petra.jpg';
    return _FeaturePage(
      title: ar ? 'استكشف بالواقع المعزز' : 'Explore in AR',
      subtitle:
          ar
              ? 'قارن المشهد الحالي بحكاية المكان'
              : 'See the story layered over the landscape',
      children: [
        _LocalPhoto(
          path: image,
          height: 300,
          radius: 26,
          overlay: PositionedDirectional(
            start: 14,
            bottom: 14,
            child: _FeaturePill(icon: Icons.history_edu_rounded, text: label),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _place,
          decoration: InputDecoration(
            labelText: ar ? 'الموقع' : 'Location',
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          items:
              ['Petra', 'Wadi Rum', 'Jerash']
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        ar
                            ? {
                              'Petra': 'البتراء',
                              'Wadi Rum': 'وادي رم',
                              'Jerash': 'جرش',
                            }[p]!
                            : p,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _place = v ?? 'Petra'),
        ),
        const SizedBox(height: 14),
        Text(
          ar ? 'حرّك المؤشر عبر الزمن' : 'Move through time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(value: _era, onChanged: (v) => setState(() => _era = v)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ar ? 'قديم' : 'Past'),
            Text(label),
            Text(ar ? 'حديث' : 'Present'),
          ],
        ),
        const SizedBox(height: 12),
        _FeaturePill(
          icon: Icons.info_outline_rounded,
          text: ar ? 'معاينة تفاعلية تجريبية' : 'Interactive preview demo',
        ),
        const SizedBox(height: 7),
        Text(
          ar
              ? 'لا يوجد حالياً وصول للكاميرا أو نموذج ثلاثي الأبعاد؛ هذه الشاشة تعرض استكشافاً بصرياً فقط.'
              : 'Camera access and a 3D reconstruction model are not configured; this screen is a visual time-slider demo.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// Reusable visual language: warm paper, deep desert ink, rounded photo cards,
// and a restrained gold action color inspired by the reference design screens.
class _FeaturePage extends StatelessWidget {
  const _FeaturePage({
    required this.title,
    this.subtitle,
    required this.children,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
      children: [
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ...children,
      ],
    ),
  );
}

class _FeatureHero extends StatelessWidget {
  const _FeatureHero({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.caption,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String eyebrow, title, caption, actionLabel;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A4033), Color(0xFF28251F)],
      ),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE4C98E), size: 27),
        const SizedBox(height: 16),
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFFE4C98E),
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          caption,
          style: const TextStyle(color: Colors.white70, height: 1.45),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.tonalIcon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: Text(actionLabel),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.warmBrown),
          ),
      ],
    ),
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.ar,
    required this.joined,
    required this.onOpen,
    required this.onJoin,
  });
  final _TravelGroupData group;
  final bool ar, joined;
  final VoidCallback onOpen, onJoin;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LocalPhoto(path: group.image, height: 155, radius: 0),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar ? group.titleAr : group.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                ar ? group.detailAr : group.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppColors.warmBrown,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.people}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: AppColors.warmBrown,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ar ? group.placeAr : group.place,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onOpen,
                    child: Text(ar ? 'التفاصيل' : 'Details'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onJoin,
                      child: Text(
                        joined
                            ? (ar ? 'تم الانضمام' : 'Joined')
                            : (ar ? 'انضم للمجموعة' : 'Join group'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onOpen,
                    tooltip: ar ? 'فتح المجموعة' : 'Open group',
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.ar,
    required this.onTap,
  });
  final _ActivityData activity;
  final bool ar;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _LocalPhoto(path: activity.image, width: 116, height: 150, radius: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? activity.titleAr : activity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FeaturePill(
                    icon: Icons.place_outlined,
                    text: ar ? activity.placeAr : activity.place,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ar ? activity.dateAr : activity.date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.price,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.ar});
  final Map<String, String> ticket;
  final bool ar;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.desertGold.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: AppColors.warmBrown,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? ticket['titleAr'] ?? '' : ticket['title'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  ar ? ticket['placeAr'] ?? '' : ticket['place'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  ar
                      ? '${ticket['dateAr']} · ${ticket['price']}'
                      : '${ticket['date']} · ${ticket['price']}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.ar,
    required this.onAdd,
  });
  final _ProductData product;
  final bool ar;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LocalPhoto(
            path: product.image,
            height: double.infinity,
            radius: 0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar ? product.titleAr : product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                ar ? product.placeAr : product.place,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.warmBrown,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onAdd,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.add_shopping_cart_outlined,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PassportStampRow extends StatelessWidget {
  const _PassportStampRow({
    required this.place,
    required this.ar,
    required this.unlocked,
    required this.onTap,
  });
  final Place place;
  final bool ar, unlocked;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor:
            unlocked
                ? AppColors.desertGold.withValues(alpha: .2)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          unlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
          color: unlocked ? AppColors.warmBrown : Theme.of(context).hintColor,
        ),
      ),
      title: Text(
        ar ? place.nameAr : place.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(ar ? place.locationAr : place.location),
      trailing: TextButton(
        onPressed: unlocked ? null : onTap,
        child: Text(
          unlocked
              ? (ar ? 'مكتمل' : 'Stamped')
              : (ar ? 'افتح الختم' : 'Unlock'),
        ),
      ),
    ),
  );
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({
    required this.title,
    required this.number,
    required this.icon,
    required this.onTap,
  });
  final String title, number;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.desertGold.withValues(alpha: .15),
        child: Icon(icon, color: AppColors.warmBrown),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(number),
      trailing: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.call_rounded),
        tooltip: 'Call',
      ),
    ),
  );
}

class _PlanDayCard extends StatelessWidget {
  const _PlanDayCard({
    required this.day,
    required this.title,
    required this.places,
  });
  final String day, title, places;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 9),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.desertGold.withValues(alpha: .18),
        child: const Icon(Icons.route_rounded, color: AppColors.warmBrown),
      ),
      title: Text(
        '$day · $title',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(places),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.desertGold.withValues(alpha: .14),
        child: Icon(icon, color: AppColors.warmBrown),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_rounded),
      onTap: onTap,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(icon, color: AppColors.warmBrown, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.desertGold.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.warmBrown),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.warmBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.desertGold,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
  );
}

class _EmptyFeature extends StatelessWidget {
  const _EmptyFeature({
    required this.icon,
    required this.title,
    required this.detail,
    required this.action,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail, action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 34),
    child: Column(
      children: [
        Icon(icon, size: 48, color: AppColors.warmBrown),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 13),
        OutlinedButton(onPressed: onTap, child: Text(action)),
      ],
    ),
  );
}

class _LocalPhoto extends StatelessWidget {
  const _LocalPhoto({
    required this.path,
    this.width,
    required this.height,
    required this.radius,
    this.overlay,
  });
  final String path;
  final double? width;
  final double height;
  final double radius;
  final Widget? overlay;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => const ColoredBox(
                  color: Color(0xFF716047),
                  child: Icon(
                    Icons.landscape_rounded,
                    color: Colors.white70,
                    size: 34,
                  ),
                ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    ),
  );
}

class _TravelGroupData {
  const _TravelGroupData({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.place,
    required this.placeAr,
    required this.detail,
    required this.detailAr,
    required this.people,
    required this.date,
    required this.dateAr,
    required this.image,
  });
  final String id,
      title,
      titleAr,
      place,
      placeAr,
      detail,
      detailAr,
      date,
      dateAr,
      image;
  final int people;
}

class _ActivityData {
  const _ActivityData({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.place,
    required this.placeAr,
    required this.date,
    required this.dateAr,
    required this.price,
    required this.image,
    required this.description,
    required this.descriptionAr,
  });
  final String id,
      title,
      titleAr,
      place,
      placeAr,
      date,
      dateAr,
      price,
      image,
      description,
      descriptionAr;
}

class _ProductData {
  const _ProductData(
    this.id,
    this.title,
    this.titleAr,
    this.place,
    this.placeAr,
    this.price,
    this.image,
  );
  final String id, title, titleAr, place, placeAr, price, image;
}
