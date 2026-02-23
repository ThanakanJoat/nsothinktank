import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class SubscriptionItem {
  final String branchId;
  final String tableId; // Can be a category ID if tableID not pertinent, but let's stick to IDs
  final String title;
  final String? type; // 'category' or 'table' or 'chart'

  SubscriptionItem({required this.branchId, required this.tableId, required this.title, this.type});

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'tableId': tableId,
    'title': title,
    'type': type,
  };

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) => SubscriptionItem(
    branchId: json['branchId'],
    tableId: json['tableId'],
    title: json['title'],
    type: json['type'],
  );
}

class SubscriptionManager {
  static const String _key = 'subscriptions';

  static Future<List<SubscriptionItem>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((j) => SubscriptionItem.fromJson(j)).toList();
  }

  static Future<void> addSubscription(SubscriptionItem item) async {
    final subs = await getSubscriptions();
    // Check dupe. Note: For categories, sub_id might be relevant or not. 
    // In catalog.dart, categories have 'id' (cat_id) and 'sub_id'.
    // We will assume unique key is branchId + tableId.
    if (!subs.any((s) => s.branchId == item.branchId && s.tableId == item.tableId)) {
      subs.insert(0, item); 
      await _saveSubscriptions(subs);
      AnalyticsManager.logEvent('subscribe', parameters: {
        'branch_id': item.branchId,
        'table_id': item.tableId,
        'title': item.title
      });
    }
  }

  static Future<void> removeSubscription(String branchId, String tableId) async {
    final subs = await getSubscriptions();
    subs.removeWhere((s) => s.branchId == branchId && s.tableId == tableId);
    await _saveSubscriptions(subs);
    AnalyticsManager.logEvent('unsubscribe', parameters: {
      'branch_id': branchId,
      'table_id': tableId
    });
  }

  static Future<bool> isSubscribed(String branchId, String tableId) async {
    final subs = await getSubscriptions();
    return subs.any((s) => s.branchId == branchId && s.tableId == tableId);
  }

  static const String _dismissedKey = 'dismissed_notifications';

  static Future<void> dismissNotification(String branchId, String tableId, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_dismissedKey);
    Map<String, String> dismissed = {};
    if (jsonStr != null) {
      dismissed = Map<String, String>.from(json.decode(jsonStr));
    }
    String key = "${branchId}_$tableId";
    dismissed[key] = timestamp; // Store update timestamp
    await prefs.setString(_dismissedKey, json.encode(dismissed));
  }

  static Future<bool> isDismissed(String branchId, String tableId, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_dismissedKey);
    if (jsonStr == null) return false;
    
    Map<String, String> dismissed = Map<String, String>.from(json.decode(jsonStr));
    String key = "${branchId}_$tableId";
    
    if (dismissed.containsKey(key)) {
      // Logic adjusted: We check if the stored dismissal timestamp matches the current update timestamp.
      // If it matches, user has dismissed THIS specific update.
      // If the API returns a NEW timestamp (newer update), it won't match, so we return false (show notif).
      return dismissed[key] == timestamp;
    }
    return false;
  }

  static Future<void> _saveSubscriptions(List<SubscriptionItem> subs) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = json.encode(subs.map((s) => s.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
