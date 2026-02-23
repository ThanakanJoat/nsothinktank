import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/getapi/get_config.dart';
import 'package:nsothinktank/getapi/get_maxmin.dart';
import 'package:nsothinktank/getapi/get_name.dart';
import 'package:nsothinktank/overrides.dart';
import 'package:nsothinktank/pages/key_data/catalog.dart';
import 'package:nsothinktank/pages/key_data/pages/build_inherited_widget.dart';
import 'package:nsothinktank/pages/main_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_menu/flutter_menu.dart';
import 'package:nsothinktank/getapi/get_data.dart';
import 'package:nsothinktank/getapi/get_freq.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:http/http.dart' as http;
import 'package:app_popup_menu/app_popup_menu.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'popmenu_class.dart';
import 'freqmenu_class.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/bookmark_manager.dart';

import 'package:nsothinktank/utils/subscription_manager.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class DataTablePage extends StatefulWidget {
  DataTablePage({Key? key}) : super(key: key);

  @override
  DataTablePageState createState() => DataTablePageState();
}

class DataTablePageState extends State<DataTablePage> {
  late List<GetData> _getDataFromAPI;
  late List<GetTitle> _getTitleFromAPI;
  late GetConfig _getConfig;
  bool loaddata = false;
  bool loadconfig = false;
  bool loadmenu = false;
  bool loadfmenu = false;
  String? bid, tid, turl;
  late AppPopupMenu<String> titleMenu;
  late AppPopupMenu<String> freqMenu;
  late List<PopupMenuItem<String>> _menu = [];
  late List<PopupMenuItem<String>> _fmenu = [];
  late List<GetFreq> _getFreqFromAPI;
  late final WebViewController controller;
  bool _isWebReady = false;
  double _webViewHeight = 400.0;
  bool _isBookmarked = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
    // Initialize standard data
    this.getData();
    this.getConfig();
    this.getMenu();
    this.getFreq();

    // Initialize WebViewController after frame to get arguments
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      final route = ModalRoute.of(context);

      if (route != null && route.settings.arguments != null) {
        final Map? arguments = route.settings.arguments as Map?;

        if (arguments != null) {
          bid = arguments['id'].toString();
          tid = arguments['sub_id'].toString();
          // Use show_table_url from constants.dart
          turl = '$show_table_url${arguments['id']}&tid=${arguments['sub_id']}';

          _checkBookmarkStatus();
          _checkSubscriptionStatus();

          if (turl != null) {
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..addJavaScriptChannel(
                'PageHeight',
                onMessageReceived: (JavaScriptMessage message) {
                  if (mounted) {
                    setState(() {
                      double? h = double.tryParse(message.message);
                      if (h != null && h > 100) {
                          _webViewHeight = h + 20; // Add buffer
                      }
                    });
                  }
                },
              )
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (String url) {
                     controller.runJavaScript('''
                        document.body.style.zoom = "0.8"; 
                        // Send height
                        setTimeout(function() {
                            PageHeight.postMessage(document.body.scrollHeight.toString());
                        }, 500);
                     ''');
                  }
                )
              )
              ..loadRequest(Uri.parse(turl!));
            setState(() {
              _isWebReady = true;
            });
          }
        }
      }
    });

    titleMenu = MenuClass<String>(
        key: const Key('MenuClass'),
        onSelected: (String value) {
            if (bid != null) {
              AnalyticsManager.logEvent('view_additional_data', parameters: {
                'branch_id': bid,
                'table_id': value
              });
              Navigator.pushReplacementNamed(context, '/datatable',
                  arguments: {
                    'id': bid,
                    'sub_id': '$value'
                  });
            }
        });

    freqMenu = FreqMenuClass<String>(
        key: const Key('FreqMenuClass'),
        onSelected: (String value) {
             if (bid != null) {
              InheritedData.of(freqMenu.context!)?.data = value;
              AnalyticsManager.logEvent('change_frequency', parameters: {
                'branch_id': bid,
                'table_id': value
              });
              Navigator.pushReplacementNamed(context, '/datatable',
                  arguments: {
                    'id': bid,
                    'sub_id': '$value'
                  });
            }
        });
  }

  Future<void> _checkSubscriptionStatus() async {
    if (bid != null && tid != null) {
      bool status = await SubscriptionManager.isSubscribed(bid!, tid!);
      if (mounted) {
        setState(() {
          _isSubscribed = status;
        });
      }
    }
  }

  Future<void> _toggleSubscription() async {
    if (bid == null || tid == null || !loadconfig) return;

    if (_isSubscribed) {
      await SubscriptionManager.removeSubscription(bid!, tid!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ยกเลิกการติดตามแล้ว")));
    } else {
      await SubscriptionManager.addSubscription(SubscriptionItem(
        branchId: bid!,
        tableId: tid!,
        title: _getConfig.tableName,
        type: 'table'
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ติดตามรายการนี้แล้ว")));
    }
    
    _checkSubscriptionStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    if (bid != null && tid != null) {
      bool status = await BookmarkManager.isBookmarked(bid!, tid!);
      if (mounted) {
        setState(() {
          _isBookmarked = status;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (bid == null || tid == null || !loadconfig) return;

    if (_isBookmarked) {
      await BookmarkManager.removeBookmark(bid!, tid!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ยกเลิกการบันทึกแล้ว")));
    } else {
      await BookmarkManager.addBookmark(BookmarkItem(
        branchId: bid!,
        tableId: tid!,
        title: _getConfig.tableName,
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("บันทึกรายการแล้ว")));
    }
    
    _checkBookmarkStatus();
  }

  Future<List<GetFreq>> getFreq() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map arguments = route.settings.arguments as Map;
        var url = Uri.parse(
            '${baseURL}get_freq.php?bid=${arguments['id']}&tid=${arguments['sub_id']}');
        var response = await http.get(url);
        if (mounted) {
          setState(() {
            _getFreqFromAPI = getFreqFromJson(response.body);
            loadfmenu = true;
            _fmenu.clear();
            for (var j = 0; j < _getFreqFromAPI.length; j++) {
              _fmenu.add(PopupMenuItem(
                  value: '${_getFreqFromAPI[j].freq}',
                  child: Text('${_getFreqFromAPI[j].freqName}')));
            }
          });
        }
      }
    });
    return []; // Placeholder as real return is handled via setState
  }

  Future<List<GetData>> getData() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
       final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map arguments = route.settings.arguments as Map;
        var url = Uri.parse(
            '${baseURL}get_data.php?bid=${arguments['id']}&tid=${arguments['sub_id']}');
        var response = await http.get(url);
         if (mounted) {
          setState(() {
            _getDataFromAPI = getDataFromJson(response.body);
            loaddata = true;
          });
         }
      }
    });
    return [];
  }

  Future<List<GetTitle>> getMenu() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
       final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map arguments = route.settings.arguments as Map;
        var url = Uri.parse(
            '${baseURL}get_title.php?bid=${arguments['id']}&tid=${arguments['sub_id']}');
        var response = await http.get(url);
        if (mounted) {
          setState(() {
            _getTitleFromAPI = getTitleFromJson(response.body);
            loadmenu = true;
            _menu.clear();
             for (var i = 0; i < _getTitleFromAPI.length; i++) {
              _menu.add(PopupMenuItem(
                  value: '${_getTitleFromAPI[i].tableId}',
                  child: Text('${_getTitleFromAPI[i].tableName}')));
            }
          });
        }
      }
    });
    return [];
  }

  Future<void> getConfig() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map arguments = route.settings.arguments as Map;
        var url = Uri.parse(
            '${baseURL}get_config.php?bid=${arguments['id']}&tid=${arguments['sub_id']}');
        var response = await http.get(url);
        if (mounted) {
          setState(() {
            _getConfig = getConfigFromJson(response.body);
            loadconfig = true;
          });
        }
      }
    });
  }

  Widget getFreqWid() {
    if (loadfmenu && _fmenu.isNotEmpty) {
      String initialVal = '5';
      bool exists = _fmenu.any((item) => item.value == tid);
      if (exists) {
        initialVal = tid!;
      } else if (_fmenu.isNotEmpty) {
         initialVal = _fmenu.first.value ?? '5';
      }

      return freqMenu.set(
          initialValue: initialVal,
          menuItems: _fmenu,
          offset: const Offset(0, 45),
          icon: Icon(Icons.list_alt, color: AppTheme.primaryColor),
          padding: EdgeInsets.zero,
      );
    } else {
      return Icon(Icons.list_alt, color: Colors.grey);
    }
  }

  Widget getWidget() {
    if (loadmenu) {
      return titleMenu.set(
        menuItems: _menu,
        offset: const Offset(0, -200), // Adjust offset to show above
        icon: Row(
            children: [
                Icon(Icons.add_circle, color: Colors.red[400]),
                const SizedBox(width: 4),
                 Text("ข้อมูลเพิ่มเติม", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ]
        ),
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context).platform == TargetPlatform.android
        ? Theme.of(context)
        : AppTheme.lightTheme;
        
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSubscribed ? Icons.notifications_active : Icons.notifications_none),
            color: _isSubscribed ? Colors.orange : Colors.white,
            onPressed: _toggleSubscription,
            tooltip: 'ติดตามข่าวสาร',
          ),
          const SizedBox(width: 8),
        ],
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
            // Custom Navigation Bar / Toolbar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildNavButton(
                      icon: Icons.list_alt,
                      label: "ความถี่",
                      onTap: () {}, // Already handled by popup menu trigger if we wrap it differently, but here we might need to trigger the menu
                      child: SizedBox(height: 24, width: 24, child: getFreqWid()), 
                  ),
                  _buildNavButton(
                    icon: Icons.pie_chart,
                    label: "กราฟ",
                    onTap: () {
                       if (bid != null && tid != null) {
                         Navigator.pushReplacementNamed(context, '/checkbarchart',
                                    arguments: {'id': bid, 'sub_id': tid});
                       }
                    },
                  ),
                  _buildNavButton(
                    icon: Icons.table_chart,
                    label: "ตาราง",
                    isActive: true,
                    onTap: () {
                      // Already on table
                    },
                  ),
                  _buildNavButton(
                    icon: Icons.info_outline,
                    label: "คำอธิบาย",
                    onTap: () {
                      if (bid != null && tid != null) {
                        Navigator.pushReplacementNamed(context, '/metadata',
                          arguments: {'id': bid, 'sub_id': tid});
                      }
                    },
                  ),
                  _buildNavButton(
                    icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    label: "บันทึก",
                    isActive: _isBookmarked,
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: (loaddata && loadconfig && loadmenu && loadfmenu && _isWebReady) 
              ? SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, kToolbarHeight + 36),
                  child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${_getConfig.tableName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_getConfig.measure.isNotEmpty)
                                Text(
                                  '(${_getConfig.measure})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                     color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 16),
                              Container(
                                height: _webViewHeight,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: WebViewWidget(controller: controller),
                                ),
                              ),
                            ]
                          )
                         )
                      ),
                )
              : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: kToolbarHeight + 20, 
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               InkWell(
                 onTap: () => Navigator.pushReplacementNamed(context, '/catalog'),
                   child: Row(
                     children: [
                       Icon(Icons.arrow_back_ios, color: theme.primaryColor),
                       Text("ย้อนกลับ", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                     ],
                   ),
               ),
              // Right side menu trigger
                getWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false, Widget? child}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child ?? Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey[600]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppTheme.primaryColor : Colors.grey[600], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

