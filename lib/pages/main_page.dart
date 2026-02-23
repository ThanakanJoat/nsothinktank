import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nsothinktank/pages/app_manual.dart';
import 'package:open_store/open_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:nsothinktank/models/notification_item.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:nsothinktank/getapi/get_data.dart';
import 'package:nsothinktank/getapi/get_dashboard.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:nsothinktank/models/search_item.dart';
import 'package:nsothinktank/getapi/get_config.dart'; // Added for metadata search
import 'package:nsothinktank/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nsothinktank/utils/subscription_manager.dart';
import 'package:intl/intl.dart';
import 'package:nsothinktank/utils/branch_icons.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

// Standalone main for testing - can be ignored or removed if not used
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class HeroSlideData {
  final String branchId;
  final String tableId;
  final String title;
  final List<DashboardRecord> data;
  final String latestValue;
  final String latestYear;
  final String unit;
  final String details; // New field for breakdown
  final String timestamp;
  final bool isLoading;

  HeroSlideData({
    required this.branchId,
    required this.tableId,
    required this.title, 
    required this.data, 
    this.latestValue = "...", 
    this.latestYear = "...", 
    this.unit = "",
    this.details = "",
    this.timestamp = "",
    this.isLoading = true
  });
}

class _MainPageState extends State<MainPage> {
  // Dashboard Data
  List<HeroSlideData> _slides = [];
  Map<String, bool> _dashboardSubscriptions = {};
  int _currentSlide = 0;
  bool _isLoading = true;

  // Search and Notifications
  List<SearchItem> _allSearchableTables = [];
  List<SearchItem> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  int _notificationCount = 0; // Add notification count

  String _errorMsg = "";



  @override
  void initState() {
    super.initState();
    // AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'home'});
    _fetchDashboardData();
    _fetchSearchableTables();
    _fetchNotificationCount(); // Fetch count on init
  }

  Future<void> _fetchDashboardData() async {
    try {
      final url = Uri.parse('https://thaistat.nso.go.th/api/get_dashboard.php'); 
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        // ... (Parsing logic similar to before, but wrapped to catch parsing specific errors)
        try {
            List<GetDashboard> dashboardItems = getDashboardFromJson(response.body);
            
            List<HeroSlideData> newSlides = [];
            final itemsToProcess = dashboardItems.take(10).toList();

            for (var item in itemsToProcess) {
              List<DashboardRecord> records = item.records;
              
              if (records.isNotEmpty) {
                records.sort((a, b) => a.seq.compareTo(b.seq));
              }

              String val = "--";
              String period = "";
              String details = "";
              
              if (records.isNotEmpty) {
                  DashboardRecord last = records.last;
                  
                  bool useLeft = last.datal.isNotEmpty;
                  String rawVal = useLeft ? last.datal : last.datar;
                  List<String> rawValues = useLeft ? last.datalValues : last.datarValues;
                  
                  if (rawValues.isEmpty && rawVal.contains('|')) {
                      rawValues = rawVal.split('|');
                  } else if (rawValues.isEmpty && rawVal.isNotEmpty) {
                      rawValues = [rawVal];
                  }

                  double totalVal = _parseDataValue(rawVal);
                  final formatter = NumberFormat("#,###.##");
                  val = formatter.format(totalVal);
                  
                  period = last.periodLabel.isNotEmpty ? last.periodLabel : last.tyear;
                  
                  if (item.columns.isNotEmpty && rawValues.length == item.columns.length) {
                      List<String> detailParts = [];
                      for (int i = 0; i < item.columns.length; i++) {
                          double? v = double.tryParse(rawValues[i].replaceAll(',', '').trim());
                          String fmtV = v != null ? formatter.format(v) : rawValues[i];
                          detailParts.add("${item.columns[i]} $fmtV");
                      }
                      details = detailParts.join("   ");
                  }
              }

              newSlides.add(HeroSlideData(
                branchId: item.branchId,
                tableId: item.tableId,
                title: item.tableName,
                data: records,
                latestValue: val,
                latestYear: period, 
                isLoading: false,
                unit: item.unit,
                details: details,
                timestamp: item.timestamp
              ));
            }

            if (mounted) {
              setState(() {
                _slides = newSlides;
                _isLoading = false;
                _errorMsg = "";
              });
              _checkDashboardSubscriptions();
            }
        } catch (parseError) {
             print("Parsing Error: $parseError");
             if (mounted) setState(() {
               _isLoading = false; 
               _errorMsg = "Data Parse Error: $parseError"; 
             });
        }

      } else {
         if (mounted) setState(() {
            _isLoading = false;
            _errorMsg = "Server Error: ${response.statusCode}";
         });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = "Connection Error: $e";
        });
      }
    }
  }
  
  // Helper to parse data values that might contain pipes '|'
  double _parseDataValue(String rawVal) {
    if (rawVal.isEmpty) return 0.0;
    
    // Remove commas first
    String cleanVal = rawVal.replaceAll(',', '');
    
    // Check for pipe
    if (cleanVal.contains('|')) {
       List<String> parts = cleanVal.split('|');
       double sum = 0.0;
       for (var part in parts) {
          double? v = double.tryParse(part.trim());
          if (v != null) sum += v;
       }
       return sum;
    } else {
       return double.tryParse(cleanVal) ?? 0.0;
    }
  }

  Future<void> _checkDashboardSubscriptions() async {
    final subs = await SubscriptionManager.getSubscriptions();
    Map<String, bool> newSubs = {};
    for (var slide in _slides) {
      String key = "${slide.branchId}_${slide.tableId}";
      newSubs[key] = subs.any((s) => s.branchId == slide.branchId && s.tableId == slide.tableId);
    }
    if (mounted) {
      setState(() {
        _dashboardSubscriptions = newSubs;
      });
    }
  }
  
  Future<void> _toggleDashboardSubscription(HeroSlideData slide) async {
    String key = "${slide.branchId}_${slide.tableId}";
    bool isSubbed = _dashboardSubscriptions[key] ?? false;

    if (isSubbed) {
      await SubscriptionManager.removeSubscription(slide.branchId, slide.tableId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ยกเลิกการติดตามแล้ว"), duration: Duration(seconds: 1)));
    } else {
      await SubscriptionManager.addSubscription(SubscriptionItem(
        branchId: slide.branchId,
        tableId: slide.tableId,
        title: slide.title,
        type: 'chart'
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ติดตามรายการนี้แล้ว"), duration: Duration(seconds: 1)));
    }
    _checkDashboardSubscriptions();
  }

  Future<void> _populateMetadata(String branchId, List<GetTitle> titles) async {
    // Limit to first 20 tables to avoid overwhelming API, or implement a queue
    // Since we need to search "definitions" (metaTerms) and "source" (metaSource)
    for (var title in titles) {
       try {
          // Fetch config for each table to get metadata
          // Optimization: Check if we already have it? (No simple way without complex state)
          // We will fetch quietly
          final url = Uri.parse('${baseURL}get_config.php?bid=$branchId&tid=${title.tableId}');
          final response = await http.get(url);
          if (response.statusCode == 200) {
             final config = getConfigFromJson(response.body);
             
             if (mounted) {
               setState(() {
                  // Update the existing item in _allSearchableTables
                  final index = _allSearchableTables.indexWhere((t) => t.branchId == branchId && t.tableId == title.tableId);
                  if (index != -1) {
                     _allSearchableTables[index] = SearchItem(
                       branchId: branchId,
                       tableId: title.tableId,
                       tableName: title.tableName,
                       branchName: _allSearchableTables[index].branchName,
                       metaTerms: config.metaTerms,
                       metaSource: config.metaSource
                     );
                  }
               });
             }
          }
       } catch (e) {
         // Silently fail for background fetch
       }
       // Small delay to be nice to server
       await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _fetchSearchableTables() async {
      // Pre-fetch titles for major categories for local search
      final Map<String, String> branchMap = {
        '101': 'ประชากร', '102': 'แรงงาน', '103': 'การศึกษา', '104': 'ศาสนา', '105': 'สุขภาพ',
        '106': 'สวัสดิการสังคม', '107': 'หญิงและชาย', '108': 'รายได้และรายจ่ายของครัวเรือน',
        '109': 'ยุติธรรม ความมั่นคง การเมือง และการปกครอง', '210': 'บัญชีประชาชาติ',
        '211': 'เกษตรและประมง', '212': 'อุตสาหกรรม', '213': 'พลังงาน', '214': 'การค้าและราคา',
        '215': 'ขนส่งและโลจิสติกส์', '216': 'เทคโนโลยีสารสนเทศและการสื่อสาร', '217': 'การท่องเที่ยวและกีฬา',
        '218': 'การเงิน การธนาคาร และการประกันภัย', '219': 'การคลัง', '220': 'วิทยาศาสตร์ เทคโนโลยี และนวัตกรรม',
        '321': 'ทรัพยากรธรรมชาติและสิ่งแวดล้อม'
      };
      
      final categories = branchMap.keys.toList();

      for (var id in categories) {
         try {
           final url = Uri.parse('${baseURL}get_title.php?bid=$id&tid=');
           final response = await http.get(url);
           if (response.statusCode == 200) {
             final titles = getTitleFromJson(response.body);
             
             if (mounted) {
               setState(() {
                 _allSearchableTables.addAll(titles.map((t) => SearchItem(
                   branchId: id,
                   tableId: t.tableId,
                   tableName: t.tableName,
                   branchName: branchMap[id] ?? "",
                   // We don't have meta yet. It needs get_config. 
                 )));
               });
               
               // Background fetch for metadata? (Optional optimization)
               _populateMetadata(id, titles);
             }
           }
         } catch (e) {
           print("Error pre-fetching titles for $id: $e");
         }
      }
  }

  void _onSearchChanged(String query) {
     if (query.isEmpty) {
       setState(() {
         _searchResults = [];
         _isSearching = false;
       });
       return;
     }
     
     setState(() {
       _isSearching = true;
       _searchResults = _allSearchableTables.where((t) => 
          t.tableName.toLowerCase().contains(query.toLowerCase()) || 
          t.branchName.toLowerCase().contains(query.toLowerCase()) ||
          (t.metaTerms != null && t.metaTerms!.toLowerCase().contains(query.toLowerCase())) ||
          (t.metaSource != null && t.metaSource!.toLowerCase().contains(query.toLowerCase()))
       ).take(10).toList();
     });

    // Track search behavior
    if (query.length >= 3) {
      AnalyticsManager.logEvent('search_data', parameters: {
        'query': query,
        'results_count': _searchResults.length
      });
      if (_searchResults.isEmpty) {
        AnalyticsManager.logEvent('search_no_results', parameters: {'query': query});
      }
    }
  }

  Future<void> _fetchNotificationCount() async {
    final subs = await SubscriptionManager.getSubscriptions();
    if (subs.isEmpty) {
      if (mounted) setState(() => _notificationCount = 0);
      return;
    }

    try {
      final url = Uri.parse('https://thaistat.nso.go.th/api/get_notification.php');
      final response = await http.get(url);
      List<NotificationItem> apiNotifications = [];
      
      if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          apiNotifications = jsonList.map((j) => NotificationItem.fromJson(j)).toList();
      }

      int count = 0;
      for (var sub in subs) {
          var match = apiNotifications.firstWhere(
            (n) => n.branchId == sub.branchId && n.tableId == sub.tableId,
            orElse: () => NotificationItem(branchId: '', tableId: '', tableName: '', seq: 0, subtitle: '', lastUpdated: '', timestamp: '')
          );

          if (match.branchId.isNotEmpty) {
             String currentTimestamp = match.timestamp;
             bool dismissed = await SubscriptionManager.isDismissed(sub.branchId, sub.tableId, currentTimestamp);
             if (!dismissed) {
               count++;
             }
          }
      }

      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }

    } catch (e) {
      print("Error fetching notification count: $e");
    }
  }

  void _showNotifications() async {
     final subs = await SubscriptionManager.getSubscriptions();
     if (subs.isEmpty) {
        // If no subscriptions, show default empty state
        _showNotificationSheet([]);
        return;
     }

     try {
        final url = Uri.parse('https://thaistat.nso.go.th/api/get_notification.php');
        final response = await http.get(url);
        List<NotificationItem> apiNotifications = [];
        
        if (response.statusCode == 200) {
           final List<dynamic> jsonList = json.decode(response.body);
           apiNotifications = jsonList.map((j) => NotificationItem.fromJson(j)).toList();
        }

        // Map subscriptions to notification data
        List<Map<String, dynamic>> displayItems = [];
        
        for (var sub in subs) {
           // Find matching API data
           var match = apiNotifications.firstWhere(
             (n) => n.branchId == sub.branchId && n.tableId == sub.tableId,
             orElse: () => NotificationItem(branchId: '', tableId: '', tableName: '', seq: 0, subtitle: '', lastUpdated: '', timestamp: '')
           );

           String currentTimestamp = match.branchId.isNotEmpty ? match.timestamp : "";
           
           // Check if dismissed locally using TIMESTAMP
           // If timestamp changes (new update), isDismissed returns false, so notification reappears.
           if (await SubscriptionManager.isDismissed(sub.branchId, sub.tableId, currentTimestamp)) {
             continue; // Skip if dismissed
           }

           if (match.branchId.isNotEmpty) {
              displayItems.add({
                'sub': sub,
                'subtitle': match.subtitle.isNotEmpty ? match.subtitle : "รอการอัปเดตข้อมูล",
                'last_updated': match.lastUpdated,
                'timestamp': match.timestamp, // Store timestamp for sorting
              });
           } else {
              // Fallback if not in API yet
              displayItems.add({
                'sub': sub,
                'subtitle': "รอการอัปเดตข้อมูล",
                'last_updated': "",
                'timestamp': "" // Empty timestamp for fallback
              });
           }
        }
        
        // Sort by timestamp descending (newest first)
        displayItems.sort((a, b) {
           String timeA = a['timestamp'] ?? '';
           String timeB = b['timestamp'] ?? '';
           if (timeA.isEmpty && timeB.isEmpty) return 0;
           if (timeA.isEmpty) return 1; // Empty timestamp goes last
           if (timeB.isEmpty) return -1;
           return timeB.compareTo(timeA); // Descending order
        });
        
        _showNotificationSheet(displayItems);

     } catch (e) {
        print("Error fetching notifications: $e");
        // Fallback to local data only
        List<Map<String, dynamic>> displayItems = subs.map((s) => {
           'sub': s,
           'subtitle': "ไม่สามารถโหลดข้อมูลล่าสุดได้",
           'last_updated': ""
        }).toList();
        _showNotificationSheet(displayItems);
     }
  }

  void _showNotificationSheet(List<Map<String, dynamic>> items) {
     showModalBottomSheet(
       context: context, 
       backgroundColor: Colors.transparent,
       builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(items.isNotEmpty ? "รายการที่ติดตาม (${items.length})" : "การแจ้งเตือน", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                  ],
                ),
                const Divider(),
                if (items.isNotEmpty)
                   Expanded(
                     child: ListView.separated(
                       shrinkWrap: true,
                       itemCount: items.length,
                       separatorBuilder: (context, index) => const Divider(height: 1),
                       itemBuilder: (context, index) {
                         final item = items[index];
                         SubscriptionItem sub = item['sub'];
                     String subtitle = item['subtitle'];

                     return ListTile(
                         leading: CircleAvatar(
                           backgroundColor: Colors.orange.withOpacity(0.1),
                           child: Icon(BranchIcons.getIcon(sub.branchId), color: Colors.orange),
                         ),
                         title: Text(sub.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                         subtitle: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(subtitle),
                             if (item['timestamp'] != null && item['timestamp'].isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 2.0),
                                 child: Text(
                                   _formatRelativeTime(item['timestamp']),
                                   style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                 ),
                               )
                           ],
                         ),
                         trailing: IconButton(
                           icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                           onPressed: () async {
                              // User request: clicking X only dismisses the notification, doesn't unsubscribe.
                              await SubscriptionManager.dismissNotification(sub.branchId, sub.tableId, item['timestamp'] ?? '');
                              _fetchNotificationCount(); // Update badge count
                              Navigator.pop(context); 
                              _showNotifications(); 
                           },
                         ),
                       onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/chart_page', arguments: {'id': sub.branchId, 'sub_id': sub.tableId});
                       },
                     );
                       },
                     ),
                   )
                else
                    const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("ไม่มีการแจ้งเตือน")))
              ],
            ),
          );
       }
     );
  }

  // ... (buildHeader updated below)

  String _formatRelativeTime(String timestamp) {
    try {
      final DateTime dt = DateTime.parse(timestamp);
      final List<String> months = [
        "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
        "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."
      ];
      final String month = months[dt.month - 1];
      final int year = (dt.year + 543) % 100;
      
      return "${dt.day} $month $year";
    } catch (e) {
      return "";
    }
  }

  Widget _buildSearchSection(ThemeData theme) {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 20),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "ค้นหาข้อมูลสถิติ (เช่น ประชากร, แรงงาน)...",
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            if (_isSearching && _searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                ),
                child: Column(
                   children: _searchResults.map((title) {
                      return ListTile(
                         visualDensity: VisualDensity.compact,
                         leading: Icon(BranchIcons.getIcon(title.branchId ?? ''), size: 24, color: theme.primaryColor),
                         title: Text(title.tableName, maxLines: 1, overflow: TextOverflow.ellipsis),
                         trailing: const Icon(Icons.chevron_right, size: 20),
                         onTap: () {
                            if (title.branchId != null && title.tableId != null) {
                              Navigator.pushNamed(context, '/datatable', arguments: {'id': title.branchId, 'sub_id': title.tableId});
                              AnalyticsManager.logEvent('search_item_selected', parameters: {
                                'query': _searchController.text,
                                'branch_id': title.branchId,
                                'table_id': title.tableId,
                                'table_name': title.tableName
                              });
                            }
                         },
                      );
                   }).toList(),
                ),
              )
            else if (_isSearching && _searchResults.isEmpty && _searchController.text.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("ไม่พบข้อมูลที่ค้นหา", style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
               )
         ],
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    // Removed FutureBuilder to prevent unnecessary loading delays
    final theme = AppTheme.lightTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       // Hero / Highlight Section Carousel
                       const SizedBox(height: 10),
                       _buildHeroCarousel(theme),
                       
                       const SizedBox(height: 10), // Reduced spacing
                       
                       // Menu Grid
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: Text("บริการข้อมูลสถิติ", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                       ),
                       const SizedBox(height: 5), // Reduced spacing
                       _buildMenuGrid(context, theme),

                       // Search Section
                       const SizedBox(height: 20),
                       _buildSearchSection(theme),
                       
                       const SizedBox(height: 20), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70, // Increased from 60 to be safer
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Expanded(child: _buildBottomNavItem(context, Icons.chat_bubble_outline, "มาดีแชท", onTap: () {
                    Navigator.pushReplacementNamed(context, '/madeechat');
                    AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'madeechat'});
                 })),
                 Expanded(child: _buildBottomNavItem(context, Icons.bookmark_border, "บันทึก", onTap: () {
                   Navigator.pushReplacementNamed(context, '/bookmark');
                   AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'bookmark'});
                 })),
                 Expanded(child: _buildBottomNavItem(context, Icons.menu_book, "คู่มือ", onTap: () {
                   Navigator.pushReplacementNamed(context, '/manual');
                   AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'manual'});
                 })),
                 Expanded(child: _buildBottomNavItem(context, Icons.feedback_outlined, "ข้อเสนอแนะ", onTap: () {
                   Navigator.pushReplacementNamed(context, '/feedback');
                   AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'feedback'});
                 })),
                 Expanded(child: _buildBottomNavItem(context, Icons.contact_support, "ติดต่อเรา", onTap: () {
                   Navigator.pushReplacementNamed(context, '/contact');
                   AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'contact'});
                 })),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: theme.primaryColor,
      child: Row(
        children: [
          Image.asset('assets/images/nso.png', width: 45, height: 45),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "สำนักงานสถิติแห่งชาติ",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Text(
                  "National Statistical Office",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification Button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _notificationCount > 0 ? Colors.orange : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: _notificationCount > 0 ? [
                    BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)
                  ] : []
                ),
                child: IconButton(
                  icon: Icon(
                    _notificationCount > 0 ? Icons.notifications_active : Icons.notifications_outlined, 
                    color: Colors.white
                  ),
                  onPressed: _showNotifications,
                  tooltip: "การแจ้งเตือน",
                ),
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeroCarousel(ThemeData theme) {
      // 1. Show Loading
      if (_isLoading) {
         return SizedBox(height: 280, child: const Center(child: CircularProgressIndicator()));
      }
      
      // 2. Show Error
      if (_errorMsg.isNotEmpty) {
         return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 16),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMsg.length > 100 ? _errorMsg.substring(0, 100) + "..." : _errorMsg, 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.red, fontSize: 12)
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMsg = "";
                    });
                    _fetchDashboardData();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("ลองใหม่อีกครั้ง"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  ),
                )
              ],
            ),
         );
      }
      
      // 3. Show Empty or Data
      if (_slides.isEmpty) return const SizedBox(height: 100, child: Center(child: Text("ไม่มีข้อมูลกราฟ")));
      
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 280,
              viewportFraction: 0.92,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;
                  });
              },
            ),
            items: _slides.map((slide) {
              return Builder(
                builder: (BuildContext context) {
                  return _buildHeroSection(theme, slide);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _slides.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : theme.primaryColor)
                      .withOpacity(_currentSlide == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ],
      );
  }

  Widget _buildHeroSection(ThemeData theme, HeroSlideData slide) {
     bool isSubbed = _dashboardSubscriptions["${slide.branchId}_${slide.tableId}"] ?? false;

     return InkWell(
       onTap: () {
         if (slide.branchId.isNotEmpty && slide.tableId.isNotEmpty) {
           Navigator.pushNamed(context, '/checkbarchart', arguments: {'id': slide.branchId, 'sub_id': slide.tableId});
           AnalyticsManager.logEvent('view_dashboard_card', parameters: {
             'branch_id': slide.branchId,
             'table_id': slide.tableId,
             'title': slide.title
           });
         }
       },
       child: Container(
         margin: const EdgeInsets.symmetric(horizontal: 4),
         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
         decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [theme.primaryColor, theme.primaryColor.withBlue(100)]
           ),
           borderRadius: BorderRadius.circular(24),
           boxShadow: [
              BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
           ]
         ),
         child: slide.isLoading 
           ? Center(child: CircularProgressIndicator(color: Colors.white))
           : Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(BranchIcons.getIcon(slide.branchId), color: Colors.white.withOpacity(0.9), size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text("${slide.title} ${slide.latestYear}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                             const SizedBox(height: 4),
                            Text("${slide.latestValue}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(slide.unit, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            if (slide.details.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Text(slide.details, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                               ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           if (slide.timestamp.isNotEmpty)
                             Text(
                               "${_formatRelativeTime(slide.timestamp)}",
                               style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                             ),
                           const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.5))
                            ),
                            child: const Text("ดูเพิ่มเติม", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: IgnorePointer( // Ignore touches on chart so InkWell gets them
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        primaryXAxis: CategoryAxis(
                          isVisible: true,
                          labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          labelPlacement: LabelPlacement.onTicks,
                          maximumLabels: 5, 
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true, header: '', format: 'point.y'),
                        series: <CartesianSeries>[
                          SplineAreaSeries<DashboardRecord, String>(
                            dataSource: slide.data,
                            xValueMapper: (DashboardRecord data, _) => data.periodLabel.isNotEmpty ? data.periodLabel : data.tyear,
                            yValueMapper: (DashboardRecord data, _) {
                                return _parseDataValue(data.datal.isNotEmpty ? data.datal : data.datar);
                            },
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderColor: Colors.white,
                            borderWidth: 3,
                            name: slide.title,
                            animationDuration: 1500,
                            markerSettings: MarkerSettings(isVisible: true, height: 4, width: 4, color: Colors.white, borderColor: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
               ],
             ),
       ),
     );
  }

  Widget _buildMenuGrid(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate item width to fill space - aiming for 2 columns, but flexible
        double itemWidth = (constraints.maxWidth - 20) / 2; // -20 for spacing
        double aspectRatio = itemWidth / 130; // Increased height to prevent overflow

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, 
          padding: const EdgeInsets.symmetric(horizontal: 20),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio, // Dynamic aspect ratio to fill width
          children: [
            _buildServiceBanner(context, 'ข้อมูลสำคัญ', Icons.folder_shared, Colors.blue, '/catalog'),
            _buildServiceBanner(context, 'ข้อมูลจังหวัด', Icons.map, Colors.orange, '/province'),
            _buildServiceBanner(context, 'Infographic', Icons.pie_chart, Colors.purple, '/infographic'),
            _buildServiceBanner(context, 'ปฏิทินข้อมูล', Icons.calendar_month, Colors.green, '/calendar'),
          ],
        );
      }
    );
  }

  Widget _buildServiceBanner(BuildContext context, String title, IconData icon, Color color, String route) {
     return InkWell(
       onTap: () {
         Navigator.pushReplacementNamed(context, route);
         AnalyticsManager.logEvent('view_menu', parameters: {'menu_route': route, 'menu_title': title});
       },
       borderRadius: BorderRadius.circular(16),
       child: Container(
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
             BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
           ],
           border: Border.all(color: color.withOpacity(0.1), width: 1)
         ),
         child: Stack(
           children: [
             Positioned(
               right: -10,
               bottom: -10,
               child: Icon(icon, size: 80, color: color.withOpacity(0.1)),
             ),
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                     child: Icon(icon, color: color, size: 24),
                   ),
                   const Spacer(),
                   Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                 ],
               ),
             )
           ],
         ),
       ),
     );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, {bool isActive = false, required VoidCallback onTap}) {
    final theme = AppTheme.lightTheme;
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(8),
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(icon, color: isActive ? theme.primaryColor : Colors.grey[700]),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, // Base size
                    color: isActive ? theme.primaryColor : Colors.grey[700],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              )
           ],
         ),
       ),
    );
  }

  Future<void> _launchURL() async {
    const url = 'https://www.nso.go.th';
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchStoreURL() async {
     // ...
  }
}

class Init {
  Init._();
  static final instance = Init._();
  Future initialize() async {
    // Reduced wait time for better UX, or keep it if mandatory
    await Future.delayed(const Duration(seconds: 3)); 
  }
}
