import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/demo_session.dart';
import 'journal_entry.dart';

/// Local-first journal cache, isolated per authenticated user or demo role.
/// Remote sync uses Supabase when the migration and private bucket are installed.
class JournalRepository {
  JournalRepository._();
  static final instance = JournalRepository._();
  SupabaseClient get _client => Supabase.instance.client;
  String get _userId =>
      _client.auth.currentUser?.id ?? 'demo:${DemoSession.role ?? 'tourist'}';
  String get _cacheKey => 'tourathi.journal.v2.${_userId.replaceAll(':', '_')}';
  String _likesKey(String id) => 'tourathi.journal.likes.$id';
  String _commentsKey(String id) => 'tourathi.journal.comments.$id';

  Future<bool> toggleLike(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _likesKey(entryId);
    final ids = prefs.getStringList(key) ?? <String>[];
    final wasLiked = ids.contains(_userId);
    if (wasLiked) {
      ids.remove(_userId);
    } else {
      ids.add(_userId);
    }
    await prefs.setStringList(key, ids);
    if (_client.auth.currentUser != null) {
      try {
        final q = _client.from('travel_journal_likes');
        if (wasLiked) {
          await q.delete().eq('entry_id', entryId).eq('user_id', _userId);
        } else {
          await q.upsert({
            'entry_id': entryId,
            'user_id': _userId,
          }, onConflict: 'entry_id,user_id');
        }
      } catch (_) {
        /* local reaction remains usable offline */
      }
    }
    return !wasLiked;
  }

  Future<int> likeCount(String entryId) async {
    if (_client.auth.currentUser != null) {
      try {
        final rows = await _client
            .from('travel_journal_likes')
            .select('user_id')
            .eq('entry_id', entryId);
        return (rows as List).length;
      } catch (_) {}
    }
    return (await SharedPreferences.getInstance())
            .getStringList(_likesKey(entryId))
            ?.length ??
        0;
  }

  Future<List<String>> comments(String entryId) async {
    if (_client.auth.currentUser != null) {
      try {
        final rows = await _client
            .from('travel_journal_comments')
            .select('body')
            .eq('entry_id', entryId)
            .order('created_at');
        return (rows as List)
            .whereType<Map<String, dynamic>>()
            .map((r) => r['body'] as String? ?? '')
            .toList();
      } catch (_) {}
    }
    return (await SharedPreferences.getInstance()).getStringList(
          _commentsKey(entryId),
        ) ??
        <String>[];
  }

  Future<void> addComment(String entryId, String body) async {
    if (_client.auth.currentUser != null) {
      await _client.from('travel_journal_comments').insert({
        'entry_id': entryId,
        'user_id': _userId,
        'body': body,
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = _commentsKey(entryId);
    final comments = prefs.getStringList(key) ?? <String>[];
    comments.add(body);
    await prefs.setStringList(key, comments);
  }

  Future<List<JournalEntry>> loadMine() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    var local = <JournalEntry>[];
    if (raw != null) {
      try {
        local =
            (jsonDecode(raw) as List)
                .whereType<Map<String, dynamic>>()
                .map(JournalEntry.fromLocal)
                .toList();
      } catch (_) {}
    }
    if (_client.auth.currentUser == null) return local;
    try {
      final rows = await _client
          .from('travel_journal_entries')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      final remote =
          (rows as List)
              .whereType<Map<String, dynamic>>()
              .map(JournalEntry.fromJson)
              .toList();
      final byId = {for (final e in remote) e.id: e};
      for (final e in local) {
        if (e.pendingSync || !byId.containsKey(e.id)) byId[e.id] = e;
      }
      final merged =
          byId.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _store(merged);
      return merged;
    } catch (_) {
      return local;
    }
  }

  Future<List<JournalEntry>> loadCommunity() async {
    if (_client.auth.currentUser == null) {
      return (await loadMine()).where((entry) => entry.isShared).toList();
    }
    try {
      final rows = await _client
          .from('travel_journal_entries')
          .select()
          .eq('visibility', 'shared')
          .order('created_at', ascending: false)
          .limit(50);
      return (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(JournalEntry.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> save(JournalEntry entry) async {
    var stored = entry.copyWith(pendingSync: _client.auth.currentUser != null);
    final records = [...await loadMine()]..removeWhere((e) => e.id == entry.id);
    records.insert(0, stored);
    await _store(records);
    if (_client.auth.currentUser != null) {
      // Do not publish an entry while its selected image failed to reach the
      // private bucket. The device copy remains intact and can be retried.
      if (entry.photoBase64 != null && entry.photoPath == null) return false;
      final payload =
          stored.toJson()
            ..remove('photo_base64')
            ..remove('pending_sync');
      try {
        await _client
            .from('travel_journal_entries')
            .upsert(payload, onConflict: 'id');
        stored = stored.copyWith(pendingSync: false);
        final synced = [...records]..removeWhere((e) => e.id == entry.id);
        synced.insert(0, stored);
        await _store(synced);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<String?> uploadPhoto(String entryId, List<int> bytes) async {
    if (_client.auth.currentUser == null) return null;
    final path = '$_userId/$entryId.jpg';
    try {
      await _client.storage
          .from('journal-media')
          .uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(JournalEntry entry) async {
    final records = [...await loadMine()]..removeWhere((e) => e.id == entry.id);
    await _store(records);
    if (_client.auth.currentUser != null) {
      try {
        await _client
            .from('travel_journal_entries')
            .delete()
            .eq('id', entry.id);
      } catch (_) {
        throw StateError(
          'Local entry deleted, but cloud deletion failed. Retry when online.',
        );
      }
      if (entry.photoPath != null) {
        try {
          await _client.storage.from('journal-media').remove([
            entry.photoPath!,
          ]);
        } catch (_) {}
      }
    }
  }

  Future<void> _store(List<JournalEntry> entries) async {
    final ok = await (await SharedPreferences.getInstance()).setString(
      _cacheKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw StateError('Could not save this entry on this device.');
  }
}
