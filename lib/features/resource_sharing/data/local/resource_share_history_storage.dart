import 'dart:convert';

import 'package:RescueNetBD/features/resource_sharing/domain/models/resource_share_history_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceShareHistoryStorage {
  static const String _historyKey = 'resource_share_history';

  Future<void> saveShare(ResourceShareHistoryItem item, {int maxItems = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getHistory();

    final updated = [item, ...existing];
    if (updated.length > maxItems) {
      updated.removeRange(maxItems, updated.length);
    }

    final jsonList = updated.map((entry) => entry.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  Future<List<ResourceShareHistoryItem>> getHistory({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return [];
    }

    final list = decoded
        .whereType<Map>()
        .map((json) => ResourceShareHistoryItem.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();

    if (limit == null || limit >= list.length) {
      return list;
    }
    return list.take(limit).toList();
  }
}
