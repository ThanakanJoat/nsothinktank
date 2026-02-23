import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AnalyticsManager {
  static const String _userIdKey = 'analytics_user_id';
  static String? _cachedUserId;
  static String? _cachedAppVersion;

  // Initialize and get the unique user ID (generated once per install)
  static Future<String> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    if (userId == null) {
      userId = _generateUserId();
      await prefs.setString(_userIdKey, userId);
    }
    _cachedUserId = userId;
    return userId;
  }

  // Get real App Version from pubspec.yaml
  static Future<String> getAppVersion() async {
    if (_cachedAppVersion != null) return _cachedAppVersion!;
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _cachedAppVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      return _cachedAppVersion!;
    } catch (e) {
      return "unknown";
    }
  }

  static String _generateUserId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        16, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Log an event to the server
  static Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      final userId = await getUserId();
      final appVersion = await getAppVersion();
      final url = Uri.parse('https://thaistat.nso.go.th/api/insert_log.php');
      
      // Fix: Clearly distinguish between branch_id and table_id
      // Parameters prioritized: branch_id, table_id (or sub_id)
      String branchId = parameters?['branch_id']?.toString() ?? '';
      String tableId = parameters?['table_id']?.toString() ?? parameters?['sub_id']?.toString() ?? '';
      
      // If branch_id is still empty, check if it was sent as category_id or id
      if (branchId.isEmpty) {
        branchId = parameters?['category_id']?.toString() ?? parameters?['id']?.toString() ?? '';
      }

      final body = {
        'user_id': userId,
        'event_name': eventName,
        'branch_id': branchId,
        'table_id': tableId,
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
        'app_version': appVersion,
        'event_details': parameters != null ? jsonEncode(parameters) : '',
      };

      final response = await http.post(url, body: body);
      
      print("Analytics tracked: $eventName (Branch: $branchId, Table: $tableId)");
      if (response.statusCode == 200) {
         print("Analytics Server Response: ${response.body}");
      } else {
         print("Analytics Server Error: ${response.statusCode}");
      }

    } catch (e) {
      print("Analytics Exception: $e");
    }
  }
}
