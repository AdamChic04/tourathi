import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/demo_session.dart';
import '../../core/providers/app_provider.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../ai_planner/saved_plans_store.dart';
import 'journal_entry.dart';
import 'journal_repository.dart';

class TravelJournalScreen extends StatefulWidget {
  const TravelJournalScreen({super.key});
  @override
  State<TravelJournalScreen> createState() => _TravelJournalScreenState();
}

class _TravelJournalScreenState extends State<TravelJournalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));
  List<JournalEntry> _mine = [], _feed = [];
  final Set<String> _liked = {};
  bool _loading = true;
  bool _ar = false;
  String t(String en, String ar) => _ar ? ar : en;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final a = await JournalRepository.instance.loadMine();
    final b = await JournalRepository.instance.loadCommunity();
    if (mounted) {
      setState(() {
        _mine = a;
        _feed = b;
        _loading = false;
      });
    }
  }

  void _notice(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  @override
  Widget build(BuildContext context) {
    _ar = context.watch<AppProvider>().isArabic;
    final signed = Supabase.instance.client.auth.currentUser != null;
    final role = DemoSession.role;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: Text(
          t('Travel journal', 'مذكرات السفر'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF8F7F4),
        actions: [
          IconButton(
            tooltip: t('Explore places', 'استكشف الأماكن'),
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => context.go('/main'),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(0xFF875A3F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF875A3F),
          tabs: [
            Tab(text: t('My journal', 'مذكراتي')),
            Tab(text: t('Community', 'المجتمع')),
          ],
        ),
      ),
      floatingActionButton:
          _tabs.index == 0
              ? FloatingActionButton.extended(
                onPressed: () => _compose(),
                backgroundColor: const Color(0xFF875A3F),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(t('New entry', 'إضافة ذكرى')),
              )
              : null,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabs,
                children: [
                  _mine.isEmpty
                      ? _emptyMine()
                      : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                          children: [
                            _intro(
                              t('Your Jordan memories', 'ذكرياتك في الأردن'),
                              t(
                                'Save a moment, link it to a place or trip, and choose when to share it.',
                                'احفظ لحظاتك واربطها بمكان أو رحلة واختر وقت مشاركتها.',
                              ),
                            ),
                            ..._mine.map((e) => _card(e, own: true)),
                          ],
                        ),
                      ),
                  !signed && role == null
                      ? _signInNotice()
                      : _feed.isEmpty
                      ? _emptyFeed()
                      : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                          children: [
                            _intro(
                              t('Stories from the community', 'حكايات المجتمع'),
                              t(
                                'Shared travel memories from Tourathi travellers.',
                                'ذكريات سفر يشاركها المسافرون عبر تراثي.',
                              ),
                            ),
                            ..._feed.map((e) => _card(e, own: false)),
                          ],
                        ),
                      ),
                ],
              ),
    );
  }

  Widget _intro(String h, String p) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: const Color(0xFFECE5D9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          h,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF34291F),
          ),
        ),
        const SizedBox(height: 7),
        Text(p, style: const TextStyle(height: 1.4, color: Color(0xFF685B4E))),
      ],
    ),
  );
  Widget _emptyMine() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 54,
            color: Color(0xFFAB8B6F),
          ),
          const SizedBox(height: 12),
          Text(
            t('Your travel story starts here', 'ابدأ حكايتك هنا'),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'Add a photo and a few words to remember a place or a moment. Entries stay private until you share them.',
              'أضف صورة وكلمات قليلة لتتذكر مكاناً أو لحظة. تبقى المذكرات خاصة حتى تختار مشاركتها.',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _compose,
            icon: const Icon(Icons.add),
            label: Text(t('Create your first entry', 'أنشئ أول ذكرى')),
          ),
        ],
      ),
    ),
  );
  Widget _emptyFeed() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, size: 48, color: Color(0xFFAB8B6F)),
          const SizedBox(height: 12),
          Text(
            t('No shared stories yet', 'لا توجد مشاركات بعد'),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'When travellers publish a memory, it will appear here.',
              'ستظهر هنا ذكريات المسافرين عند مشاركتها.',
            ),
          ),
        ],
      ),
    ),
  );
  Widget _signInNotice() => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 45),
          const SizedBox(height: 10),
          Text(
            t(
              'Sign in to view community stories',
              'سجل الدخول لرؤية قصص المجتمع',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/login'),
            child: Text(t('Sign in', 'تسجيل الدخول')),
          ),
        ],
      ),
    ),
  );
  Widget _card(JournalEntry e, {required bool own}) {
    final bytes = e.photoBytes;
    final date =
        '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}';
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEAE6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bytes != null)
            Image.memory(
              Uint8List.fromList(bytes),
              height: 205,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          else if (e.photoPath != null)
            FutureBuilder<String>(
              future: Supabase.instance.client.storage
                  .from('journal-media')
                  .createSignedUrl(e.photoPath!, 3600),
              builder:
                  (c, s) =>
                      s.hasData
                          ? Image.network(
                            s.data!,
                            height: 205,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (own)
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') _compose(existing: e);
                          if (v == 'delete') _delete(e);
                        },
                        itemBuilder:
                            (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(t('Edit', 'تعديل')),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(t('Delete', 'حذف')),
                              ),
                            ],
                      ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                if (e.body.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(e.body, style: const TextStyle(height: 1.4)),
                ],
                if (e.placeName != null || e.tripName != null) ...[
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (e.placeName != null)
                        _chip(Icons.place_outlined, e.placeName!),
                      if (e.tripName != null)
                        _chip(Icons.route_outlined, e.tripName!),
                    ],
                  ),
                ],
                const SizedBox(height: 11),
                Row(
                  children: [
                    Icon(
                      e.isShared ? Icons.public : Icons.lock_outline,
                      size: 16,
                      color: const Color(0xFF875A3F),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      e.isShared
                          ? t('Shared with community', 'مشاركة مع المجتمع')
                          : t('Private', 'خاصة'),
                      style: const TextStyle(
                        color: Color(0xFF875A3F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!own) ...[
                      const Spacer(),
                      FutureBuilder<int>(
                        future: JournalRepository.instance.likeCount(e.id),
                        builder:
                            (context, snapshot) => TextButton.icon(
                              onPressed: () async {
                                final liked = await JournalRepository.instance
                                    .toggleLike(e.id);
                                if (mounted) {
                                  setState(() {
                                    liked
                                        ? _liked.add(e.id)
                                        : _liked.remove(e.id);
                                  });
                                }
                              },
                              icon: Icon(
                                _liked.contains(e.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 17,
                              ),
                              label: Text('${snapshot.data ?? 0}'),
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _comments(e),
                        icon: const Icon(Icons.mode_comment_outlined, size: 17),
                        label: Text(t('Comment', 'تعليق')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData i, String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F0EB),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(i, size: 15, color: const Color(0xFF875A3F)),
        const SizedBox(width: 5),
        Text(s, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );

  Future<void> _comments(JournalEntry entry) async {
    final controller = TextEditingController();
    var rows = await JournalRepository.instance.comments(entry.id);
    if (!mounted) {
      controller.dispose();
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (dialogContext, updateDialog) => AlertDialog(
                title: Text(t('Comments', 'التعليقات')),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            t('Start the conversation.', 'ابدأ الحوار.'),
                          ),
                        ),
                      ...rows.map(
                        (comment) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.person_outline),
                          title: Text(comment),
                        ),
                      ),
                      TextField(
                        controller: controller,
                        maxLength: 280,
                        decoration: InputDecoration(
                          hintText: t('Write a comment', 'اكتب تعليقاً'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(t('Close', 'إغلاق')),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;
                      try {
                        await JournalRepository.instance.addComment(
                          entry.id,
                          value,
                        );
                        rows = [...rows, value];
                        controller.clear();
                        updateDialog(() {});
                      } catch (e) {
                        _notice(
                          t(
                            'Comment could not be saved: $e',
                            'تعذر حفظ التعليق: $e',
                          ),
                        );
                      }
                    },
                    child: Text(t('Post', 'نشر')),
                  ),
                ],
              ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _compose({JournalEntry? existing}) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final body = TextEditingController(text: existing?.body ?? '');
    final places = JordanPlaceSeed.places;
    String? placeId = existing?.placeId;
    String? tripId = existing?.tripId;
    String visibility = existing?.visibility ?? 'private';
    Uint8List? photo =
        existing?.photoBytes == null
            ? null
            : Uint8List.fromList(existing!.photoBytes!);
    String? photoPath = existing?.photoPath;
    final plans = await SavedPlansStore.instance.load();
    if (!mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        var saving = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              height: MediaQuery.sizeOf(ctx).height * .91,
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.viewInsetsOf(ctx).bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF9F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    existing == null
                        ? t('Write a memory', 'اكتب ذكرى')
                        : t('Edit memory', 'تعديل الذكرى'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      children: [
                        TextField(
                          controller: title,
                          maxLength: 80,
                          decoration: InputDecoration(
                            labelText: t('Title *', 'العنوان *'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: body,
                          minLines: 4,
                          maxLines: 7,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            labelText: t('Tell your story', 'اكتب قصتك'),
                            alignLabelWithHint: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: placeId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: t(
                              'Link a Jordan place',
                              'اربط بمكان أردني',
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(t('No place', 'بدون مكان')),
                            ),
                            ...places.map(
                              (p) => DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(_ar ? p.nameAr : p.name),
                              ),
                            ),
                          ],
                          onChanged: (v) => setSheet(() => placeId = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: tripId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: t(
                              'Link a saved trip',
                              'اربط برحلة محفوظة',
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(t('No trip', 'بدون رحلة')),
                            ),
                            ...plans.map(
                              (p) => DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(p.destination),
                              ),
                            ),
                          ],
                          onChanged: (v) => setSheet(() => tripId = v),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final x = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 78,
                              maxWidth: 1600,
                            );
                            if (x != null) {
                              photo = await x.readAsBytes();
                              photoPath = null;
                              setSheet(() {});
                            }
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            photo == null
                                ? t('Add a photo', 'إضافة صورة')
                                : t('Change photo', 'تغيير الصورة'),
                          ),
                        ),
                        if (photo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                photo!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          t('Who can see this?', 'من يمكنه رؤية ذلك؟'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'private',
                          groupValue: visibility,
                          title: Text(t('Only me', 'أنا فقط')),
                          subtitle: Text(
                            t('Private by default', 'خاصة افتراضياً'),
                          ),
                          onChanged: (v) => setSheet(() => visibility = v!),
                        ),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'shared',
                          groupValue: visibility,
                          title: Text(t('Community feed', 'مجتمع تراثي')),
                          onChanged: (v) => setSheet(() => visibility = v!),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          saving
                              ? null
                              : () async {
                                if (title.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        t(
                                          'Add a title first.',
                                          'أضف عنواناً أولاً.',
                                        ),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setSheet(() => saving = true);
                                try {
                                  final now = DateTime.now();
                                  final id =
                                      existing?.id ??
                                      'j${now.microsecondsSinceEpoch}';
                                  final matchingPlace = places.where(
                                    (p) => p.id == placeId,
                                  );
                                  final matchingTrip = plans.where(
                                    (p) => p.id == tripId,
                                  );
                                  final place =
                                      matchingPlace.isEmpty
                                          ? null
                                          : matchingPlace.first;
                                  final trip =
                                      matchingTrip.isEmpty
                                          ? null
                                          : matchingTrip.first;
                                  final user =
                                      Supabase
                                          .instance
                                          .client
                                          .auth
                                          .currentUser
                                          ?.id ??
                                      'demo:${DemoSession.role ?? 'tourist'}';
                                  if (photo != null &&
                                      Supabase
                                              .instance
                                              .client
                                              .auth
                                              .currentUser !=
                                          null) {
                                    photoPath = await JournalRepository.instance
                                        .uploadPhoto(id, photo!);
                                  }
                                  final entry = JournalEntry(
                                    id: id,
                                    userId: user,
                                    title: title.text.trim(),
                                    body: body.text.trim(),
                                    visibility: visibility,
                                    createdAt: existing?.createdAt ?? now,
                                    updatedAt: now,
                                    placeId: placeId,
                                    placeName:
                                        place == null
                                            ? null
                                            : (_ar ? place.nameAr : place.name),
                                    tripId: tripId,
                                    tripName: trip?.destination,
                                    photoBase64:
                                        photo == null
                                            ? null
                                            : base64Encode(photo!),
                                    photoPath: photoPath,
                                  );
                                  final synced = await JournalRepository
                                      .instance
                                      .save(entry);
                                  if (ctx.mounted) Navigator.pop(ctx, synced);
                                } catch (e) {
                                  if (ctx.mounted) {
                                    setSheet(() => saving = false);
                                  }
                                  _notice(
                                    t('Save failed: $e', 'فشل الحفظ: $e'),
                                  );
                                }
                              },
                      icon:
                          saving
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save_outlined),
                      label: Text(t('Save entry', 'حفظ الذكرى')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    // Keep the text controllers alive while the bottom sheet's reverse
    // transition is still painting its final frames.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    title.dispose();
    body.dispose();
    if (result != null) {
      _notice(
        result
            ? t('Entry saved and synced.', 'تم حفظ الذكرى ومزامنتها.')
            : t(
              'Saved on this device; cloud sync or photo upload is incomplete.',
              'تم الحفظ على هذا الجهاز؛ مزامنة السحابة أو رفع الصورة غير مكتمل.',
            ),
      );
      await _load();
    }
  }

  Future<void> _delete(JournalEntry entry) async {
    final yes = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(t('Delete this entry?', 'حذف هذه الذكرى؟')),
            content: Text(
              t(
                'This removes it from your journal.',
                'ستتم إزالة الذكرى من مذكراتك.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(t('Cancel', 'إلغاء')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: Text(t('Delete', 'حذف')),
              ),
            ],
          ),
    );
    if (yes != true) return;
    try {
      await JournalRepository.instance.delete(entry);
      await _load();
    } catch (e) {
      _notice('$e');
    }
  }
}
