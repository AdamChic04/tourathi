import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local demo persistence for the community and discovery
/// experiences. Cloud chat, booking, and media services are not configured.
class ExtrasStore {
  ExtrasStore._();

  static Future<bool> isJoined(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tourathi.groups.joined.$groupId') ?? false;
  }

  static Future<void> setJoined(String groupId, bool joined) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tourathi.groups.joined.$groupId', joined);
  }

  static Future<List<Map<String, String>>> loadMessages(
    String groupId,
    List<Map<String, String>> seed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tourathi.groups.messages.$groupId');
    if (raw == null) return seed;
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((item) => item.map((key, value) => MapEntry(key, '$value')))
          .toList();
    } catch (_) {
      return seed;
    }
  }

  static Future<void> saveMessages(
    String groupId,
    List<Map<String, String>> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tourathi.groups.messages.$groupId',
      jsonEncode(messages),
    );
  }

  static Future<List<Map<String, String>>> loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tourathi.demo-tickets.v1');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((item) => item.map((key, value) => MapEntry(key, '$value')))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTicket(Map<String, String> ticket) async {
    final tickets = await loadTickets();
    tickets.insert(0, ticket);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tourathi.demo-tickets.v1', jsonEncode(tickets));
  }

  static Future<Set<String>> loadStamps() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('tourathi.passport-stamps.v1') ?? []).toSet();
  }

  static Future<void> addStamp(String placeId) async {
    final stamps =
        await loadStamps()
          ..add(placeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tourathi.passport-stamps.v1', stamps.toList());
  }

  static Future<int> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tourathi.demo-cart-count.v1') ?? 0;
  }

  static Future<int> addCartItem() async {
    final count = await loadCartCount() + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tourathi.demo-cart-count.v1', count);
    return count;
  }
}
