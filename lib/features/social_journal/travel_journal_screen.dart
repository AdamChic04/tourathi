import 'dart:convert';

import 'package:flutter/material.dart';

import '../rewards/adventure_rewards_models.dart';
import '../rewards/adventure_rewards_repository.dart';
import '../rewards/reward_catalog.dart';

/// A lightweight local journal for completed trips. Its repository call writes
/// the journal entry and one points transaction together.
class TravelJournalScreen extends StatefulWidget {
  const TravelJournalScreen({super.key});

  @override
  State<TravelJournalScreen> createState() => _TravelJournalScreenState();
}

class _TravelJournalScreenState extends State<TravelJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripName = TextEditingController();
  final _destination = TextEditingController();
  final _reflection = TextEditingController();
  final AdventureRewardsRepository _repository =
      LocalAdventureRewardsRepository.instance;
  AdventureRewardsSnapshot? _snapshot;
  bool _completed = false;
  DateTime _completedAt = DateTime.now();
  bool _loading = true;
  bool _saving = false;
  Object? _error;

  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tripName.dispose();
    _destination.dispose();
    _reflection.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository.load();
      if (!mounted) return;
      setState(() {
        _snapshot = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_completed) {
      _message(
        _ar
            ? 'أكد اكتمال الرحلة قبل حفظها.'
            : 'Confirm that your trip is complete before saving it.',
      );
      return;
    }

    final tripName = _tripName.text.trim();
    final destination = _destination.text.trim();
    final dateKey = _dateKey(_completedAt);
    final canonicalTrip = [tripName, destination, dateKey]
        .map((part) => part.toLowerCase().replaceAll(RegExp(r'\s+'), ' '))
        .join('|');
    final tripId = base64Url.encode(utf8.encode(canonicalTrip));
    final entry = TravelJournalEntry(
      id: 'journal-$tripId',
      tripId: tripId,
      tripName: tripName,
      destination: destination,
      reflection: _reflection.text.trim(),
      completedAt: _completedAt,
    );

    setState(() => _saving = true);
    try {
      final result = await _repository.saveCompletedTripJournal(entry);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      if (result.status == JournalAwardStatus.earned) {
        _message(
          _ar
              ? 'تم حفظ الرحلة واكتسبت ${result.points} نقطة!'
              : 'Trip journal saved — you earned ${result.points} points!',
        );
        _tripName.clear();
        _destination.clear();
        _reflection.clear();
        setState(() => _completed = false);
      } else {
        _message(
          _ar
              ? 'تم احتساب النقاط لهذه الرحلة من قبل.'
              : 'Points have already been awarded for this trip.',
        );
      }
    } catch (_) {
      if (mounted) {
        _message(
          _ar
              ? 'تعذر حفظ المجلة. لم تُضف نقاط؛ حاول مرة أخرى.'
              : 'Could not save the journal. No points were added; please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseTripDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _completedAt.isAfter(today) ? today : _completedAt,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(() => _completedAt = selected);
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_ar ? 'مذكرات السفر' : 'Travel Journal')),
    body:
        _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _JournalError(ar: _ar, onRetry: _load)
            : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _ar
                                ? 'وثّق رحلة مكتملة'
                                : 'Journal a completed trip',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _ar
                                ? 'اكتب ذكرى رحلتك بعد انتهائها لتحصل على ${AdventureRewardsConfig.pointsPerJournaledCompletedTrip} نقطة.'
                                : 'Save a reflection after your trip is complete to earn ${AdventureRewardsConfig.pointsPerJournaledCompletedTrip} points.',
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _tripName,
                                  maxLength: 100,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: _ar ? 'اسم الرحلة' : 'Trip name',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? (_ar
                                                  ? 'أدخل اسم الرحلة'
                                                  : 'Enter a trip name')
                                              : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _destination,
                                  maxLength: 100,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: _ar ? 'الوجهة' : 'Destination',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? (_ar
                                                  ? 'أدخل الوجهة'
                                                  : 'Enter a destination')
                                              : null,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _saving ? null : _chooseTripDate,
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    label: Text(
                                      '${_ar ? 'تاريخ اكتمال الرحلة' : 'Trip completion date'} · ${_displayDate(_completedAt)}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _reflection,
                                  maxLength: 1000,
                                  minLines: 3,
                                  maxLines: 6,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    labelText:
                                        _ar
                                            ? 'ماذا تتذكر من الرحلة؟'
                                            : 'What do you remember about the trip?',
                                    alignLabelWithHint: true,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? (_ar
                                                  ? 'أضف ملاحظة قصيرة'
                                                  : 'Add a short reflection')
                                              : null,
                                ),
                                const SizedBox(height: 4),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: _completed,
                                  onChanged:
                                      _saving
                                          ? null
                                          : (value) => setState(
                                            () => _completed = value ?? false,
                                          ),
                                  title: Text(
                                    _ar
                                        ? 'أؤكد أن الرحلة مكتملة'
                                        : 'I confirm this trip is complete',
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: _saving ? null : _save,
                                    icon:
                                        _saving
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(Icons.save_outlined),
                                    label: Text(
                                      _ar
                                          ? 'احفظ المجلة واكسب النقاط'
                                          : 'Save journal and earn points',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _ar ? 'رحلاتك الموثقة' : 'Your journaled trips',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_snapshot!.journalEntries.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          _ar
                              ? 'لم توثّق أي رحلة بعد.'
                              : 'You have not journaled a trip yet.',
                        ),
                      ),
                    )
                  else
                    ..._snapshot!.journalEntries.map(
                      (entry) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.auto_stories_rounded),
                          ),
                          title: Text(entry.tripName),
                          subtitle: Text(
                            '${entry.destination}\n${entry.reflection}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.check_circle_outline),
                        ),
                      ),
                    ),
                ],
              ),
            ),
  );
}

class _JournalError extends StatelessWidget {
  const _JournalError({required this.ar, required this.onRetry});
  final bool ar;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(ar ? 'تعذر تحميل المجلة.' : 'Could not load your journal.'),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: onRetry,
          child: Text(ar ? 'إعادة المحاولة' : 'Retry'),
        ),
      ],
    ),
  );
}
