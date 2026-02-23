import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/getapi/get_config.dart';
import 'package:nsothinktank/getapi/get_maxmin.dart';
import 'package:nsothinktank/getapi/get_name.dart';
import 'package:nsothinktank/pages/key_data/catalog.dart';
import 'package:nsothinktank/pages/key_data/pages/build_inherited_widget.dart';
import 'package:nsothinktank/pages/main_page.dart';
import 'package:nsothinktank/utils/bookmark_manager.dart';
import 'package:nsothinktank/utils/subscription_manager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_menu/flutter_menu.dart';
import 'package:nsothinktank/getapi/get_data.dart';
import 'package:nsothinktank/getapi/get_freq.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:http/http.dart' as http;
import 'package:app_popup_menu/app_popup_menu.dart';
import 'popmenu_class.dart';
import 'freqmenu_class.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class MetaDataPage extends StatefulWidget {
  MetaDataPage({Key? key}) : super(key: key);

  @override
  MetaDataPageState createState() => MetaDataPageState();
}

class MetaDataPageState extends State<MetaDataPage> {
  late List<GetData> _getDataFromAPI;
  late List<GetTitle> _getTitleFromAPI;
  late GetConfig _getConfig;
  bool loaddata = false;
  bool loadconfig = false;
  bool loadmenu = false;
  bool loadfmenu = false;
  String? bid, tid;
  late AppPopupMenu<String> titleMenu;
  late AppPopupMenu<String> freqMenu;
  late List<PopupMenuItem<String>> _menu = [];
  late List<PopupMenuItem<String>> _fmenu = [];
  late List<GetFreq> _getFreqFromAPI;
  bool _isBookmarked = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback once to initialize arguments and load data
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map? arguments = route.settings.arguments as Map?;
        if (arguments != null) {
          bid = arguments['id'].toString();
          tid = arguments['sub_id'].toString();
          // Load data after setting IDs
          this.getData();
          this.getConfig();
          this.getMenu();
          this.getFreq();
          _checkBookmarkStatus();
          _checkSubscriptionStatus();
        }
      }
    });

    titleMenu = MenuClass<String>(
        key: const Key('MenuClass'),
        onSelected: (String value) {
            if (bid != null) {
              Navigator.pushReplacementNamed(context, '/checkbarchart',
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
              Navigator.pushReplacementNamed(context, '/checkbarchart',
                  arguments: {
                    'id': bid,
                    'sub_id': '$value'
                  });
            }
        });
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
        type: 'metadata'
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ติดตามรายการนี้แล้ว")));
    }
    
    _checkSubscriptionStatus();
  }

  Future<List<GetData>> getData() async {
    if (bid == null || tid == null) return [];
    var url = Uri.parse('${baseURL}get_data.php?bid=$bid&tid=$tid');
    try {
      var response = await http.get(url);
      if (mounted) {
        setState(() {
          _getDataFromAPI = getDataFromJson(response.body);
          loaddata = true;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    return [];
  }

  Future<List<GetFreq>> getFreq() async {
    if (bid == null || tid == null) return [];
     var url = Uri.parse('${baseURL}get_freq.php?bid=$bid&tid=$tid');
    try {
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
    } catch (e) {
       print('Error loading freq: $e');
    }
    return [];
  }

  Future<List<GetTitle>> getMenu() async {
    if (bid == null || tid == null) return [];
    var url = Uri.parse('${baseURL}get_title.php?bid=$bid&tid=$tid');
    try {
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
    } catch (e) {
      print('Error loading menu: $e');
    }
    return [];
  }

  Future<void> getConfig() async {
     if (bid == null || tid == null) return;
     var url = Uri.parse('${baseURL}get_config.php?bid=$bid&tid=$tid');
     try {
       var response = await http.get(url);
       if (mounted) {
        setState(() {
          _getConfig = getConfigFromJson(response.body);
          loadconfig = true;
        });
       }
     } catch (e) {
       print('Error loading config: $e');
     }
  }

  Widget getFreqWid() {
    if (loadfmenu) {
      return freqMenu.set(
          initialValue: '5',
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
        offset: const Offset(0, -200),
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
                      onTap: () {}, 
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
                    onTap: () {
                       if (bid != null && tid != null) {
                        Navigator.pushReplacementNamed(context, '/datatable',
                          arguments: {'id': bid, 'sub_id': tid});
                      }
                    },
                  ),
                  _buildNavButton(
                    icon: Icons.info_outline,
                    label: "คำอธิบาย",
                    isActive: true, // we are on metadata page
                    onTap: () {
                      // Already here
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
              child: loadconfig
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                             elevation: 2,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                             child: Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Column(
                                 children: [
                                   Text(
                                    "${_getConfig.tableName}",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                 ],
                               )
                             )
                          ),
                          const SizedBox(height: 16),
                          _buildInfoSection(theme, "คำนิยาม", _getConfig.metaTerms),
                          _buildInfoSection(theme, "หน่วยวัด", _getConfig.metaMeasure),
                          _buildInfoSection(theme, "แหล่งที่มา", _getConfig.metaSource),
                          _buildInfoSection(theme, "ติดต่อข้อมูลเพิ่มเติม", _getConfig.metaUrl),
                        ],
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

  Widget _buildInfoSection(ThemeData theme, String title, String content) {
    if (content.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             Container(
               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
               decoration: BoxDecoration(
                 color: theme.primaryColor.withOpacity(0.1),
                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
               ),
               child: Text(
                 title,
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.primaryColor),
               ),
             ),
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Html(data: content),
             )
           ],
        ),
      ),
    );
  }
}
