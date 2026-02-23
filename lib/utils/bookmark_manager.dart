import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class BookmarkItem {
  final String branchId;
  final String tableId;
  final String title;

  BookmarkItem({required this.branchId, required this.tableId, required this.title});

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'tableId': tableId,
    'title': title,
  };

  factory BookmarkItem.fromJson(Map<String, dynamic> json) => BookmarkItem(
    branchId: json['branchId'],
    tableId: json['tableId'],
    title: json['title'],
  );
}

class BookmarkManager {
  static const String _key = 'bookmarks';

  static Future<List<BookmarkItem>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((j) => BookmarkItem.fromJson(j)).toList();
  }

  static Future<void> addBookmark(BookmarkItem item) async {
    final bookmarks = await getBookmarks();
    if (!bookmarks.any((b) => b.branchId == item.branchId && b.tableId == item.tableId)) {
      bookmarks.insert(0, item); // Add to top
      await _saveBookmarks(bookmarks);
      AnalyticsManager.logEvent('bookmark_add', parameters: {
        'branch_id': item.branchId,
        'table_id': item.tableId,
        'title': item.title
      });
    }
  }

  static Future<void> removeBookmark(String branchId, String tableId) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.branchId == branchId && b.tableId == tableId);
    await _saveBookmarks(bookmarks);
    AnalyticsManager.logEvent('bookmark_remove', parameters: {
      'branch_id': branchId,
      'table_id': tableId
    });
  }

  static Future<bool> isBookmarked(String branchId, String tableId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.branchId == branchId && b.tableId == tableId);
  }

  static Future<void> _saveBookmarks(List<BookmarkItem> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = json.encode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
