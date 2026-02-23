import 'package:flutter/material.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/bookmark_manager.dart';
import 'package:nsothinktank/utils/branch_icons.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<BookmarkItem> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final items = await BookmarkManager.getBookmarks();
    if (mounted) {
      setState(() {
        _bookmarks = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(int index) async {
    final item = _bookmarks[index];
    await BookmarkManager.removeBookmark(item.branchId, item.tableId);
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
           onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.bookmark, color: theme.primaryColor),
                   const SizedBox(width: 8),
                  Text(
                    "รายการที่บันทึก",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : _bookmarks.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text("ไม่มีรายการที่บันทึก", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _bookmarks.length,
                        itemBuilder: (context, index) {
                          final item = _bookmarks[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(BranchIcons.getIcon(item.branchId), color: theme.primaryColor),
                              ),
                              title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeBookmark(index),
                              ),
                              onTap: () {
                                 Navigator.pushNamed(context, '/chart_page', arguments: {'id': item.branchId, 'sub_id': item.tableId});
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
