import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:nsothinktank/getapi/get_config.dart';
import 'package:nsothinktank/getapi/get_data.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:nsothinktank/getapi/get_freq.dart';
import 'package:nsothinktank/pages/key_data/pages/data_table.dart';
import 'package:nsothinktank/pages/key_data/pages/meta_data.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';
import 'package:nsothinktank/utils/bookmark_manager.dart';
import 'package:nsothinktank/utils/subscription_manager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_popup_menu/app_popup_menu.dart';
import 'package:nsothinktank/pages/key_data/pages/popmenu_class.dart';
import 'package:nsothinktank/pages/key_data/pages/freqmenu_class.dart';
import 'package:nsothinktank/pages/key_data/pages/build_inherited_widget.dart'; 

class ChartPage extends StatefulWidget {
  ChartPage({Key? key}) : super(key: key);

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  List<GetData> _getDataFromAPI = [];
  List<GetTitle> _getTitleFromAPI = [];
  GetConfig? _getConfig;
  bool loaddata = false;
  bool loadconfig = false;
  bool loadmenu = false;
  bool hasError = false;
  String errorMessage = '';
  int loadcomplete = 0;
  var bid, tid;
  late AppPopupMenu<String> titleMenu;
  late AppPopupMenu<String> freqMenu;
  late List<PopupMenuItem<String>> _menu = [];
  late List<PopupMenuItem<String>> _fmenu = [];
  late List<GetFreq> _getFreqFromAPI;
  bool _isBookmarked = false;
  bool _isSubscribed = false;


  late ZoomPanBehavior _zoomPanBehavior;
  String _chartType = 'column'; // 'column', 'line', 'pie'
  bool _showDataR = false; // Toggle to show 'datar' (right measure)
  var url;
  String? _selectedYear;
  List<String> _availableYears = [];

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.xy,
    );
    this.getData();
    this.getConfig();
    this.getTitle();
    this.getFreq();
    
    titleMenu = MenuClass<String>(
        key: const Key('MenuClass'),
        onSelected: (String value) {
          if (ModalRoute.of(context)?.settings.arguments != null) {
              final Map arguments =
                  ModalRoute.of(context)!.settings.arguments as Map;
              InheritedData.of(titleMenu.context!)?.data = value;
              
              AnalyticsManager.logEvent('view_additional_data', parameters: {
                'branch_id': arguments['id'].toString(),
                'table_id': value
              });

              Navigator.pushReplacementNamed(context, '/chart_page',
                  arguments: {
                    'id': arguments['id'].toString(),
                    'sub_id': '$value'
                  });
            }
        });

    freqMenu = FreqMenuClass<String>(
        key: const Key('FreqMenuClass'),
        onSelected: (String value) {
            if (ModalRoute.of(context)?.settings.arguments != null) {
              final Map arguments =
                  ModalRoute.of(context)!.settings.arguments as Map;
              InheritedData.of(freqMenu.context!)?.data = value;
              
              AnalyticsManager.logEvent('change_frequency', parameters: {
                'branch_id': arguments['id'].toString(),
                'table_id': value
              });

              Navigator.pushReplacementNamed(context, '/chart_page',
                  arguments: {
                    'id': arguments['id'].toString(),
                    'sub_id': '$value'
                  });
            }
        });

    super.initState();
  }

  Future<void> _checkBookmarkStatus() async {
    if (bid != null && tid != null) {
      final isBookmarked = await BookmarkManager.isBookmarked(bid.toString(), tid.toString());
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkManager.removeBookmark(bid.toString(), tid.toString());
      setState(() {
        _isBookmarked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ลบจากบันทึกแล้ว")));
    } else {
      await BookmarkManager.addBookmark(BookmarkItem(
        branchId: bid.toString(),
        tableId: tid.toString(),
        title: _getConfig?.tableName ?? "Unknown",
      ));
      setState(() {
        _isBookmarked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("บันทึกรายการแล้ว")));
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    if (bid != null && tid != null) {
      final isSubscribed = await SubscriptionManager.isSubscribed(bid.toString(), tid.toString());
      setState(() {
        _isSubscribed = isSubscribed;
      });
    }
  }

  Future<void> _toggleSubscription() async {
    if (_isSubscribed) {
      await SubscriptionManager.removeSubscription(bid.toString(), tid.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ยกเลิกการติดตามแล้ว")));
    } else {
      await SubscriptionManager.addSubscription(SubscriptionItem(
        branchId: bid.toString(),
        tableId: tid.toString(),
        title: _getConfig?.tableName ?? "Unknown",
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ติดตามรายการนี้แล้ว")));
    }
    await _checkSubscriptionStatus();
  }


  Future<List<GetData>> getData() async {
    try {
      await Future.delayed(Duration.zero);
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
        bid = arguments['id'].toString();
        tid = arguments['sub_id'].toString();

        await _checkBookmarkStatus();
        await _checkSubscriptionStatus();

        String url =
            "https://thaistat.nso.go.th/api/get_data.php?bid=" +
                bid +
                "&tid=" +
                tid;
        var response = await http.get(Uri.parse(url));
        setState(() {
          _getDataFromAPI = getDataFromJson(response.body);
          if (_getDataFromAPI.isNotEmpty) {
             _availableYears = _getDataFromAPI.map((e) => e.tyear).toSet().toList();
             // Default to "ทั้งหมด"
             if (_selectedYear == null) {
                 _selectedYear = "ทั้งหมด";
             }
          }
          loaddata = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        _getDataFromAPI = [];
        loaddata = true;
        hasError = true;
        errorMessage = "Data: $e";
      });
    }
    return _getDataFromAPI;
  }

  Future<GetConfig?> getConfig() async {
    try {
      await Future.delayed(Duration.zero);
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
        bid = arguments['id'].toString();
        tid = arguments['sub_id'].toString();

        url = "https://thaistat.nso.go.th/api/get_config.php?bid=" +
            bid +
            "&tid=" +
            tid;
        var response = await http.get(Uri.parse(url));
        
        setState(() {
          _getConfig = getConfigFromJson(response.body);
          loadconfig = true;

           // Check pipe condition
           bool hasPipe = false;
           if (_getDataFromAPI.isNotEmpty && _getDataFromAPI.first.datar.contains('|')) {
               hasPipe = true;
           }

           if (hasPipe) {
              _chartType = 'pie';
              _showDataR = true;
           } else if (_getConfig != null) {
              if (_getConfig!.graphPie == "1") {
                _chartType = 'pie';
              } else if (_getConfig!.graphLine == "1") {
                _chartType = 'line';
              } else if (_getConfig!.graphBar == "1") {
                 _chartType = 'column';
              } else {
                 _chartType = 'column'; 
              }
           }
        });
      }
    } catch (e) {
      debugPrint("Error loading config: $e");
      setState(() {
        loadconfig = true;
        hasError = true;
        errorMessage = "Config: $e";
      });
    }
    return _getConfig;
  }



  Future<List<GetTitle>> getTitle() async {
    try {
      await Future.delayed(Duration.zero);
        if (ModalRoute.of(context)?.settings.arguments != null) {
          final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
          
          url = "https://thaistat.nso.go.th/api/get_title.php?bid=" +
              arguments['id'].toString(); 
          var response = await http.get(Uri.parse(url));
          
          setState(() {
            _getTitleFromAPI = getTitleFromJson(response.body);
            loadmenu = true;
            _menu = [];
            for (var item in _getTitleFromAPI) {
              _menu.add(PopupMenuItem<String>(
                  value: item.tableId,
                  child: Text(item.tableName),
              ));
            }
          });
      }
    } catch (e) {
       debugPrint("Error loading title: $e");
       setState(() { loadmenu = true; });
    }
    return _getTitleFromAPI;
  }

  Future<List<GetFreq>> getFreq() async {
    try {
      await Future.delayed(Duration.zero);
        if (ModalRoute.of(context)?.settings.arguments != null) {
          final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
          
          url = "https://thaistat.nso.go.th/api/get_freq.php?bid=" +
              arguments['id'].toString() + "&tid=" + arguments['sub_id'].toString();
          
          var response = await http.get(Uri.parse(url));
          setState(() {
            _getFreqFromAPI = getFreqFromJson(response.body);
            _fmenu = [];
            for (int i = 0; i < _getFreqFromAPI.length; i++) {
              _fmenu.add(PopupMenuItem<String>(
                  value: _getFreqFromAPI[i].freq,
                  child:  Text(
                    _getFreqFromAPI[i].freqName,
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ));
            }
            // loadfmenu = true;
          });
        }
    } catch (e) {
       debugPrint("Error loading freq: $e");
       setState(() { /* loadfmenu = true; */ });
    }
    return _getFreqFromAPI;
  }

  Widget getFreqWid() {
    if (_fmenu.isNotEmpty) {
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

    // Return List<CartesianSeries> for Bar/Line charts
   List<CartesianSeries> _getCartesianSeries(ThemeData theme) {
    if (_getDataFromAPI.isEmpty || _getConfig == null) return [];

    List<String> cnames = _getConfig!.columnNames;
    List<String> Function(GetData) valueMapper;

    // 1. Determine Data Source (Left vs Right)
    if (_showDataR) {
       valueMapper = (d) => d.dataRList;
    } else {
       valueMapper = (d) => d.dataLList;
    }

    // 2. Determine Maximum Number of Series (Columns)
    int maxSeriesCount = 0;
    for (var item in _getDataFromAPI) {
      int len = valueMapper(item).length;
      if (len > maxSeriesCount) maxSeriesCount = len;
    }

    // 3. Define Color Palette
    List<Color> palette = [
      const Color(0xFF0F8644), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFFFFEB3B), // Yellow
      Colors.blue,
      Colors.teal,
      Colors.redAccent,
    ];

    List<CartesianSeries> seriesList = [];

    // Pre-calculate active indices to optimize and handle Naming logic
    List<int> activeIndices = [];
    for (int i = 0; i < maxSeriesCount; i++) {
         if (cnames.isNotEmpty && i >= cnames.length) continue;
         bool hasData = false;
         for (var item in _getDataFromAPI) {
             List<String> parts = valueMapper(item);
             if (i < parts.length) {
                 double? val = double.tryParse(parts[i].replaceAll(',', ''));
                 if (val != null && val != 0) {
                     hasData = true;
                     break; 
                 }
             }
         }
         if (hasData) activeIndices.add(i);
    }

    // Column and Line Charts (Multi-Series support)
    for (int i = 0; i < maxSeriesCount; i++) {
        // Filter: Skip if index exceeds column names (unless cnames is empty)
        if (cnames.isNotEmpty && i >= cnames.length) continue;

        // Check if this series has any non-zero data
        bool hasData = false;
        for (var item in _getDataFromAPI) {
             List<String> parts = valueMapper(item);
             if (i < parts.length) {
                 double? val = double.tryParse(parts[i].replaceAll(',', ''));
                 if (val != null && val != 0) {
                     hasData = true;
                     break; 
                 }
             }
        }
        if (!hasData) continue;

        // Determine Series Name
        String seriesName = "";
        if (i < cnames.length) {
            seriesName = cnames[i];
        } else {
            // Fallback: Use Table Name as requested by user
            String baseName = _getConfig!.tableName;
            if (baseName.isEmpty) baseName = "Series";

            // Smart Naming: If only 1 active series, use Table Name without index
            if (activeIndices.length == 1) {
                seriesName = baseName;
            } else {
                seriesName = "$baseName ${i+1}";
            }
        }

        Color seriesColor = palette[i % palette.length];

        if (_chartType == 'column') {
             List<GetData> source = _getDataFromAPI;
             if (_selectedYear != null && _selectedYear != "ทั้งหมด") {
                 source = _getDataFromAPI.where((e) => e.tyear == _selectedYear).toList();
             }

            seriesList.add(ColumnSeries<GetData, String>(
                name: seriesName,
                dataSource: source,
                xValueMapper: (GetData sales, _) => sales.tyear,
                yValueMapper: (GetData sales, _) {
                    List<String> parts = valueMapper(sales);
                    if (i < parts.length) {
                       return double.tryParse(parts[i].replaceAll(',', ''));
                    }
                    return null;
                },
                color: seriesColor,
                dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 10, color: Colors.grey)),
            ));
        } else {
            List<GetData> source = _getDataFromAPI;
             if (_selectedYear != null && _selectedYear != "ทั้งหมด") {
                 source = _getDataFromAPI.where((e) => e.tyear == _selectedYear).toList();
             }
            // Line Series
             seriesList.add(LineSeries<GetData, String>(
                name: seriesName,
                dataSource: source,
                xValueMapper: (GetData sales, _) => sales.tyear,
                yValueMapper: (GetData sales, _) {
                    List<String> parts = valueMapper(sales);
                    if (i < parts.length) {
                       return double.tryParse(parts[i].replaceAll(',', ''));
                    }
                    return null;
                },
                color: seriesColor,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 10, color: Colors.grey)),
            ));
        }
    }
    
    return seriesList;
  }

  // Return List<CircularSeries> for Pie charts
  List<CircularSeries> _getPieSeries(ThemeData theme) {
      if (_getDataFromAPI.isEmpty || _getConfig == null) return [];

      List<String> cnames = _getConfig!.columnNames;
      List<String> Function(GetData) valueMapper;
      if (_showDataR) { valueMapper = (d) => d.dataRList; } 
      else { valueMapper = (d) => d.dataLList; }

       // Palette
    List<Color> palette = [
      const Color(0xFF0F8644), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFFFFEB3B), // Yellow
      Colors.blue,
      Colors.teal,
      Colors.redAccent,
    ];

      // Pie Implementation: Show distribution of Columns for the SELETED Data Point
       if (_getDataFromAPI.isNotEmpty) {
           GetData targetData;
           if (_selectedYear != null && _selectedYear != "ทั้งหมด") {
               targetData = _getDataFromAPI.firstWhere((e) => e.tyear == _selectedYear, orElse: () => _getDataFromAPI.last);
           } else {
               targetData = _getDataFromAPI.last;
           }
           List<String> values = valueMapper(targetData);
           
           // Construct a local data model for Pie
           List<Map<String, dynamic>> pieData = [];
           for(int i=0; i<values.length; i++) {
               // Filter: Skip if index exceeds column names (unless cnames is empty)
               if (cnames.isNotEmpty && i >= cnames.length) continue;

               String name = (i < cnames.length) ? cnames[i] : "Col ${i+1}";
               double? val = double.tryParse(values[i].replaceAll(',', ''));
               if (val != null) {
                   pieData.add({'x': name, 'y': val, 'color': palette[i % palette.length]});
               }
           }

           return <PieSeries<Map<String, dynamic>, String>>[
               PieSeries<Map<String, dynamic>, String>(
                   dataSource: pieData,
                   xValueMapper: (Map<String, dynamic> data, _) => data['x'] as String,
                   yValueMapper: (Map<String, dynamic> data, _) => data['y'] as double,
                   pointColorMapper: (Map<String, dynamic> data, _) => data['color'] as Color,
                   dataLabelSettings: const DataLabelSettings(isVisible: true,  labelPosition: ChartDataLabelPosition.outside),
                   name: targetData.tyear // Legend title as Year
               )
           ];
       }
       return [];
  }

  Widget _buildChartWidget(ThemeData theme) {
      if (_chartType == 'pie') {
          return SfCircularChart(
             legend: Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
             tooltipBehavior: TooltipBehavior(enable: true),
             series: _getPieSeries(theme),
          );
      } else {
          return SfCartesianChart(
              zoomPanBehavior: _zoomPanBehavior,
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                majorGridLines: const MajorGridLines(width: 1),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat(),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(width: 1, dashArray: [5, 5], color: Colors.grey.withOpacity(0.2)),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true, 
                header: '', 
                canShowMarker: false, 
                format: 'point.y',
                color: theme.primaryColor,
                textStyle: TextStyle(color: Colors.white)
              ),
              series: _getCartesianSeries(theme),
          );
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
    bool isLoaded = (loadconfig == true && loaddata == true && loadmenu == true && _getConfig != null && _getDataFromAPI.isNotEmpty);

    if (isLoaded || hasError) {
      FlutterNativeSplash.remove();
    }
    
    final theme = AppTheme.lightTheme;
    // var height = MediaQuery.of(context).size.height;
    
    if (hasError) {
        return Scaffold(
             appBar: AppBar(title: const Text("ข้อผิดพลาด"), backgroundColor: theme.primaryColor),
             body: Center(
                 child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                     const Icon(Icons.error_outline, size: 64, color: Colors.red),
                     const SizedBox(height: 16),
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Text("Error: $errorMessage", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                     ),
                     const SizedBox(height: 16),
                     ElevatedButton(
                         child: const Text("ลองใหม่"), 
                         onPressed: () {
                             setState(() {
                                 hasError = false;
                                 errorMessage = '';
                                 loaddata = false; loadconfig = false; loadmenu = false;
                             });
                             this.getData();
                             this.getConfig();
                             this.getTitle();
                             this.getFreq();
                         }
                     )
                 ]
             ))
        );
    }

    return Scaffold(
      appBar: AppBar(
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
            )
          ],
        ),
        automaticallyImplyLeading: false, // Hide auto back button
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSubscribed ? Icons.notifications_active : Icons.notifications_none,
              color: _isSubscribed ? Colors.orange : Colors.white),
            onPressed: () => _toggleSubscription(),
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
             // Custom Navigation Bar
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
                      isActive: true,
                      onTap: () {},
                    ),
                    _buildNavButton(
                      icon: Icons.table_chart,
                      label: "ตาราง",
                      onTap: () {
                         if (bid != null && tid != null) {
                           Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DataTablePage(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'id': bid,
                                      'sub_id': tid
                                    },
                                  ),
                                ),
                          );
                         }
                      },
                    ),
                    _buildNavButton(
                      icon: Icons.info_outline,
                      label: "คำอธิบาย",
                      onTap: () {
                          if (bid != null && tid != null) {
                             Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MetaDataPage(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'id': bid,
                                      'sub_id': tid
                                    },
                                  ),
                                ),
                              );
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
               child: isLoaded 
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
                           // Controls Row: Scrollable to prevent overflow
                           Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  // ROW 1: Chart Types & Reset Zoom
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Chart Types
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.bar_chart, color: _chartType == 'column' ? theme.primaryColor : Colors.grey),
                                            onPressed: () => setState(() => _chartType = 'column'),
                                            tooltip: 'กราฟแท่ง',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.show_chart, color: _chartType == 'line' ? theme.primaryColor : Colors.grey),
                                            onPressed: () => setState(() => _chartType = 'line'),
                                            tooltip: 'กราฟเส้น',
                                          ),
                                          if (_getDataFromAPI.any((d) => d.datar.contains('|')))
                                            IconButton(
                                              icon: Icon(Icons.pie_chart, color: _chartType == 'pie' ? theme.primaryColor : Colors.grey),
                                              onPressed: () {
                                                  setState(() {
                                                     _chartType = 'pie';
                                                     if (_selectedYear == "ทั้งหมด" && _availableYears.isNotEmpty) {
                                                         _selectedYear = _availableYears.last;
                                                     }
                                                  });
                                              },
                                              tooltip: 'กราฟวงกลม',
                                            ),
                                        ],
                                      ),
                                      // Reset Zoom
                                      IconButton(
                                         icon: const Icon(Icons.restart_alt, color: Colors.grey),
                                         tooltip: 'รีเซ็ตการซูม',
                                         onPressed: () {
                                             _zoomPanBehavior.reset();
                                             AnalyticsManager.logEvent('chart_zoom_reset', parameters: {'table_id': tid});
                                         },
                                       ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),

                                  // ROW 2: Data Toggle & Year Selection
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       // Data Toggle
                                       if (_getConfig!.rMeasure.isNotEmpty || _getDataFromAPI.any((d) => d.datar.isNotEmpty && d.datar != "0"))
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                 InkWell(
                                                   onTap: () => setState(() => _showDataR = false),
                                                   child: Container(
                                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                     decoration: BoxDecoration(
                                                       color: !_showDataR ? theme.primaryColor : Colors.transparent,
                                                       borderRadius: BorderRadius.circular(16),
                                                     ),
                                                     child: Text(
                                                       _getConfig!.lMeasure.isNotEmpty ? _getConfig!.lMeasure : (_getConfig!.measure.isNotEmpty ? _getConfig!.measure : "ชุดข้อมูล 1"),
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         color: !_showDataR ? Colors.white : Colors.grey[700],
                                                         fontWeight: FontWeight.bold,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                                 InkWell(
                                                   onTap: () => setState(() => _showDataR = true),
                                                   child: Container(
                                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                     decoration: BoxDecoration(
                                                       color: _showDataR ? theme.primaryColor : Colors.transparent,
                                                       borderRadius: BorderRadius.circular(16),
                                                     ),
                                                     child: Text(
                                                       _getConfig!.rMeasure.isNotEmpty ? _getConfig!.rMeasure : "ชุดข้อมูล 2",
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         color: _showDataR ? Colors.white : Colors.grey[700],
                                                         fontWeight: FontWeight.bold,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                              ],
                                            ),
                                          )
                                       else 
                                          const SizedBox(), // Spacer if no toggle

                                       // Year Dropdown
                                       if (_availableYears.isNotEmpty)
                                          Container(
                                            height: 36,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: Colors.grey.shade300)
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: (_chartType == 'pie' && _selectedYear == "ทั้งหมด")
                                                       ? (_availableYears.isNotEmpty ? _availableYears.last : null)
                                                       : (_availableYears.contains(_selectedYear) || _selectedYear == "ทั้งหมด" ? _selectedYear : (_availableYears.isNotEmpty ? _availableYears.last : null)),
                                                items: [
                                                  if (_chartType != 'pie')
                                                    const DropdownMenuItem(value: "ทั้งหมด", child: Text("ทั้งหมด", style: TextStyle(fontSize: 12))),
                                                  ..._availableYears.where((y) => y != "ทั้งหมด").map((y) => DropdownMenuItem(value: y, child: Text(y, style: TextStyle(fontSize: 12))))
                                                ],
                                                onChanged: (v) {
                                                  setState(() {
                                                    _selectedYear = v;
                                                  });
                                                },
                                                icon: const Icon(Icons.arrow_drop_down, size: 20),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                           ),
                               
                               const SizedBox(height: 16),
                               Text(
                                 '${_getConfig!.tableName}',
                                 style: theme.textTheme.titleMedium?.copyWith(
                                   fontWeight: FontWeight.bold,
                                   color: theme.primaryColor,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                               // Dynamic Unit Text
                               Text(
                                   '(${_showDataR ? (_getConfig!.rMeasure.isNotEmpty ? _getConfig!.rMeasure : "หน่วย") : (_getConfig!.lMeasure.isNotEmpty ? _getConfig!.lMeasure : (_getConfig!.measure.isNotEmpty ? _getConfig!.measure : "หน่วย"))})',
                                   style: theme.textTheme.bodyMedium?.copyWith(
                                     color: Colors.grey[600],
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               
                               const SizedBox(height: 16),
                               Container(
                                 height: MediaQuery.of(context).size.height * 0.55,
                                 child: _buildChartWidget(theme),
                               ),
                        ],
                      ),
                    ),
                  ),
               )
               : const Center(child: CircularProgressIndicator()),
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
                 onTap: () => Navigator.of(context).pop(), // Just pop for back
                   child: Row(
                     children: [
                       Icon(Icons.arrow_back_ios, color: theme.primaryColor),
                       Text("ย้อนกลับ", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                     ],
                   ),
               ),
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
