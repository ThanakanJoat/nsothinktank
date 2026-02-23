import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:nsothinktank/getapi/get_config.dart';
import 'package:nsothinktank/getapi/get_data.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:nsothinktank/getapi/get_freq.dart';
// import 'package:nsothinktank/pages/key_data/pages/data_table.dart'; // No longer needed as separate page
// import 'package:nsothinktank/pages/key_data/pages/meta_data.dart'; // No longer needed as separate page
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
import 'package:flutter_html/flutter_html.dart'; // Added for Description

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
  late TransformationController _tableZoomController;
  
  // Custom Table Controllers
  late ScrollController _hBodyController;
  late ScrollController _vBodyController;
  late ScrollController _hHeadController;
  late ScrollController _vColController;
  double _tableScale = 1.0;
  double _baseScale = 1.0;

  String _chartType = 'column'; // 'column', 'line', 'pie', 'table'
  bool _showDataR = false; // Toggle to show 'datar' (right measure)
  var url;
  String? _selectedYear;
  List<String> _availableYears = [];

  @override
  void initState() {
    _tableZoomController = TransformationController();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.xy,
    );

    // Init Linked Controllers
    _hBodyController = ScrollController();
    _vBodyController = ScrollController();
    _hHeadController = ScrollController();
    _vColController = ScrollController();
    
    // Sync Logic
    _hBodyController.addListener(() {
      if (_hHeadController.hasClients && _hBodyController.offset != _hHeadController.offset) {
        _hHeadController.jumpTo(_hBodyController.offset);
      }
    });
    _hHeadController.addListener(() {
      if (_hBodyController.hasClients && _hBodyController.offset != _hHeadController.offset) {
         _hBodyController.jumpTo(_hHeadController.offset);
      }
    });

    _vBodyController.addListener(() {
      if (_vColController.hasClients && _vBodyController.offset != _vColController.offset) {
        _vColController.jumpTo(_vBodyController.offset);
      }
    });
    _vColController.addListener(() {
      if (_vBodyController.hasClients && _vBodyController.offset != _vColController.offset) {
        _vBodyController.jumpTo(_vColController.offset);
      }
    });
    
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

  @override
  void dispose() {
    _tableZoomController.dispose();
    _hBodyController.dispose();
    _vBodyController.dispose();
    _hHeadController.dispose();
    _vColController.dispose();
    super.dispose();
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

  String get currentFreqName {
    if (_getFreqFromAPI == null || _getFreqFromAPI.isEmpty) return "ความถี่";
    try {
      // tid is the current table id which represents frequency in this context if mapped correctly?
      // Wait, tid is sub_id. If sub_id changes with frequency.
      var match = _getFreqFromAPI.firstWhere((e) => e.freq == tid, orElse: () => _getFreqFromAPI.first);
      return match.freqName;
    } catch (e) {
      return "ความถี่";
    }
  }

  Widget getFreqWid() {
    if (_fmenu.isNotEmpty) {
      return freqMenu.set(
          initialValue: tid ?? '5',
          menuItems: _fmenu,
          offset: const Offset(0, 45),
          // Change from Icon to Text
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentFreqName, style: TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black87),
              ],
            ),
          ),
          padding: EdgeInsets.zero,
      );
    } else {
      return Container(
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
         decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
         ),
         child: Text("ความถี่", style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
    }
  }

  Widget _buildInfoSection(ThemeData theme, String title, String content) {
    if (content.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             Container(
               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
               decoration: BoxDecoration(
                 color: theme.primaryColor.withOpacity(0.05),
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
               ),
               child: Text(
                 title,
                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColor),
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
                       // Replace comma and parse. If fail (e.g. "-"), return 0.0 to maintain line continuity
                       return double.tryParse(parts[i].replaceAll(',', '')) ?? 0.0;
                    }
                    return 0.0;
                },
                color: seriesColor,
                width: 3,
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
             key: ValueKey('pie-$_showDataR-$_selectedYear'),
             legend: Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
             tooltipBehavior: TooltipBehavior(enable: true),
             series: _getPieSeries(theme),
          );
      } else {
          return SfCartesianChart(
              key: ValueKey('cartesian-$_showDataR-$_chartType-$_selectedYear'),
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
                numberFormat: NumberFormat.compact(), // Compact for large numbers (M, B)
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

  Widget _buildTableFromChartData(ThemeData theme) {
      if (_getDataFromAPI.isEmpty || _getConfig == null) return const Center(child: Text("ไม่มีข้อมูล"));
      
      List<String> configNames = List.from(_getConfig!.columnNames);
      List<String> Function(GetData) valueMapper;
      if (_showDataR) { valueMapper = (d) => d.dataRList; } 
      else { valueMapper = (d) => d.dataLList; }

      // Filter by year if selected
      List<GetData> displayData = _getDataFromAPI;
      if (_selectedYear != null && _selectedYear != "ทั้งหมด") {
          displayData = _getDataFromAPI.where((e) => e.tyear == _selectedYear).toList();
      }

      if (displayData.isEmpty) return const Center(child: Text("ไม่พบข้อมูลในช่วงเวลาที่เลือก"));

      // 1. Analyze data structure
      List<List<String>> allRowsData = displayData.map((d) => valueMapper(d)).toList();
      int maxCols = allRowsData.isEmpty ? 0 : allRowsData.fold(0, (max, list) => list.length > max ? list.length : max);

      // 2. Identify active columns
      List<int> activeColIndices = [];
      if (configNames.isEmpty) {
          for (int c = 0; c < maxCols; c++) {
              bool isAllZero = true;
              for (var row in allRowsData) {
                  if (c < row.length) {
                      String val = row[c];
                      if (val != "0" && val.isNotEmpty) {
                          isAllZero = false;
                          break;
                      }
                  }
              }
              if (!isAllZero) activeColIndices.add(c);
          }
          if (activeColIndices.isEmpty && maxCols > 0) activeColIndices.add(0);
      } else {
          activeColIndices = List.generate(maxCols, (i) => i);
      }
      
      // 3. Generate Header Names
      List<String> cnames = [];
      if (configNames.isNotEmpty) {
         cnames = configNames; 
      } else {
         if (activeColIndices.length == 1) {
             cnames = [_getConfig!.tableName.isNotEmpty ? _getConfig!.tableName : "ปริมาณ"];
         } else {
             cnames = List.generate(activeColIndices.length, (index) => "ข้อมูล ${index + 1}");
         }
      }

      // Final Headers and Data
      List<String> headers = ["ปีข้อมูล", ...cnames];
      List<List<String>> tableData = [];
      
      for (int index = 0; index < displayData.length; index++) {
          var item = displayData[index];
          List<String> rowRawValues = allRowsData[index];
          List<String> row = [item.tyear];
          
          for(int i=0; i < cnames.length; i++) {
              String val = "-";
              if (configNames.isNotEmpty) {
                  if (i < rowRawValues.length) val = rowRawValues[i];
              } else {
                  int originalIndex = activeColIndices[i];
                  if (originalIndex < rowRawValues.length) val = rowRawValues[originalIndex];
              }
              try {
                  String cleanVal = val.replaceAll(',', '');
                  if (double.tryParse(cleanVal) != null) {
                      double numVal = double.parse(cleanVal);
                      val = NumberFormat('#,###.##').format(numVal);
                  }
              } catch (_) {}
              row.add(val);
          }
          tableData.add(row);
      }

      // Build Freeze Panes Layout
      // Base dimensions for scale 1.0
      double rawFirstColW = 100.0;
      double rawCellW = 120.0;
      double rawRowH = 48.0;
      double rawHeaderH = 56.0;

      int totalDataCols = headers.length > 1 ? headers.length - 1 : 0;
      int totalRows = tableData.length;
      
      double rawTotalW = rawFirstColW + (totalDataCols * rawCellW);
      double rawTotalH = rawHeaderH + (totalRows * rawRowH);

      return LayoutBuilder(
        builder: (context, constraints) {
           double minScaleW = constraints.maxWidth / rawTotalW;
           double minScaleH = constraints.maxHeight / rawTotalH;
           // Fit entire table content
           double minAllowedScale = (minScaleW < minScaleH) ? minScaleW : minScaleH;
           
           // If table is small, allow some shrinking otherwise lock
           if (minAllowedScale > 1.0) minAllowedScale = 0.5;

           // Recalculate scaled dimensions
           double cellWidth = rawCellW * _tableScale;
           double firstColWidth = rawFirstColW * _tableScale;
           double rowHeight = rawRowH * _tableScale; 
           double fontSize = (14.0 * _tableScale).clamp(8.0, 24.0);
           double headerHeight = rawHeaderH * _tableScale;

           // Auto-expand columns to fill screen if content is small
           if (totalDataCols > 0) {
               double currentTotalW = firstColWidth + (totalDataCols * cellWidth);
               if (currentTotalW < constraints.maxWidth) {
                   double extraPerCol = (constraints.maxWidth - currentTotalW) / totalDataCols;
                   cellWidth += extraPerCol;
               }
           }

           return GestureDetector(
             onScaleStart: (details) {
                _baseScale = _tableScale;
             },
             onScaleUpdate: (details) {
                setState(() {
                    _tableScale = (_baseScale * details.scale).clamp(minAllowedScale, 2.0);
                });
             },
        child: Container(
             decoration: BoxDecoration(
                 border: Border.all(color: Colors.grey.shade300),
                 color: Colors.white
             ),
             child: Column(
                children: [
                   // TOP ROW (Header)
                   SizedBox(
                       height: 56.0 * _tableScale, // Header height slightly larger?
                       child: Row(
                          children: [
                             // CORNER (Fixed)
                             Container(
                                width: firstColWidth,
                                color: theme.primaryColor.withOpacity(0.1),
                                alignment: Alignment.center,
                                child: Text(headers[0], style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: theme.primaryColor)),
                             ),
                             // HEADER LIST (Scrollable Horizontal)
                             Expanded(
                                 child: SingleChildScrollView(
                                     controller: _hHeadController,
                                     scrollDirection: Axis.horizontal,
                                     physics: const NeverScrollableScrollPhysics(), 
                                     child: Row(
                                         children: headers.sublist(1).map((h) => 
                                             Container(
                                                width: cellWidth,
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                decoration: BoxDecoration(
                                                    border: Border(bottom: BorderSide(color: Colors.grey.shade300), left: BorderSide(color: Colors.grey.shade300)),
                                                    color: theme.primaryColor.withOpacity(0.05)
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(h, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.black87), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                             )
                                         ).toList()
                                     )
                                 )
                             )
                          ]
                       ),
                   ),
                   // BOTTOM SECTION
                   Expanded(
                      child: Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            // FIRST COL (Scrollable Vertical)
                            SizedBox(
                                width: firstColWidth,
                                child: SingleChildScrollView(
                                    controller: _vColController,
                                    scrollDirection: Axis.vertical,
                                    physics: const NeverScrollableScrollPhysics(), 
                                    child: Column(
                                        children: tableData.map((row) => 
                                            Container(
                                                height: rowHeight,
                                                width: firstColWidth,
                                                decoration: BoxDecoration(
                                                    border: Border(bottom: BorderSide(color: Colors.grey.shade100), right: BorderSide(color: Colors.grey.shade100)), 
                                                    color: Colors.white
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(row[0], style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
                                            )
                                        ).toList()
                                    )
                                ),
                            ),
                            // BODY (Scrollable Both)
                            Expanded(
                                child: SingleChildScrollView(
                                    controller: _vBodyController,
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                        controller: _hBodyController, // Use master horizontal controller
                                        scrollDirection: Axis.horizontal,
                                        child: Column(
                                            children: tableData.asMap().entries.map((entry) {
                                                int index = entry.key;
                                                List<String> row = entry.value;
                                                Color rowColor = index % 2 == 0 ? Colors.white : Colors.grey.shade50;
                                                return Row(
                                                    children: row.sublist(1).map((cell) => 
                                                        Container(
                                                            width: cellWidth, height: rowHeight,
                                                            decoration: BoxDecoration(
                                                                border: Border(bottom: BorderSide(color: Colors.grey.shade100), left: BorderSide(color: Colors.grey.shade100)),
                                                                color: rowColor
                                                            ),
                                                            alignment: Alignment.center,
                                                            child: Text(cell, style: TextStyle(fontSize: fontSize)),
                                                        )
                                                    ).toList()
                                                );
                                            }).toList()
                                        )
                                    )
                                )
                            )
                         ]
                      )
                   )
                ]
             )
        ),
      );
    }
  );
}

  @override
  Widget build(BuildContext context) {
    bool isLoaded = (loadconfig == true && loaddata == true && loadmenu == true && _getConfig != null && _getDataFromAPI.isNotEmpty);
    // Safety check for freqMenu
    if (!loadconfig && !loaddata) {
         // Initial Loading state handled below
    }

    final theme = AppTheme.lightTheme;
    
    if (hasError) {
        return Scaffold(
             appBar: AppBar(title: const Text("ข้อผิดพลาด"), backgroundColor: theme.primaryColor),
             body: Center(child: Text("Error: $errorMessage"))
        );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png', width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "สำนักงานสถิติแห่งชาติ",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            )
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          // MOVED: Bookmark Button
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: _toggleBookmark,
            tooltip: 'บันทึก',
          ),
          const SizedBox(width: 8),
          
          IconButton(
            icon: Icon(_isSubscribed ? Icons.notifications_active : Icons.notifications_none,
              color: _isSubscribed ? Colors.orange : Colors.white),
            onPressed: () => _toggleSubscription(),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: theme.primaryColor,
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: isLoaded 
        ? SingleChildScrollView(
          padding: const EdgeInsets.all(16), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // 8.3.1 Title & Unit & Chart Container -> Combined in Card
               Card(
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 elevation: 2,
                 margin: EdgeInsets.zero,
                 color: Colors.white,
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                        // Title
                        Text(
                           '${_getConfig!.tableName}',
                           style: theme.textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                             color: theme.primaryColor,
                           ),
                           textAlign: TextAlign.center,
                        ),
                        // Unit
                        Text(
                             '(${_showDataR ? (_getConfig!.rMeasure.isNotEmpty ? _getConfig!.rMeasure : "หน่วย") : (_getConfig!.lMeasure.isNotEmpty ? _getConfig!.lMeasure : (_getConfig!.measure.isNotEmpty ? _getConfig!.measure : "หน่วย"))})',
                             style: theme.textTheme.bodyMedium?.copyWith(
                               color: Colors.grey[600],
                             ),
                             textAlign: TextAlign.center,
                         ),
                        const SizedBox(height: 12),


                        // Chart/Table
                        _chartType == 'table' 
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: _buildTableFromChartData(theme),
                          )
                        : SizedBox(
                           height: MediaQuery.of(context).size.height * 0.55,
                           child: _buildChartWidget(theme),
                        ),
                     ],
                   ),
                 ),
               ),
               const SizedBox(height: 16),

               // 8.3.3 Controls Area
               Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))]
                  ),
                  child: Column(
                    children: [
                      // Row 1: Chart Types + Reset Zoom
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                             IconButton(
                                icon: Icon(Icons.table_chart, color: _chartType == 'table' ? theme.primaryColor : Colors.grey),
                                onPressed: () => setState(() => _chartType = 'table'),
                                tooltip: 'ตาราง',
                             ),
                             // MOVED: Reset Zoom here
                             const SizedBox(width: 8),
                             IconButton(
                              icon: const Icon(Icons.restart_alt, color: Colors.grey),
                              tooltip: 'รีเซ็ตการซูม',
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                  setState(() {
                                      _zoomPanBehavior.reset();
                                      _tableZoomController.value = Matrix4.identity();
                                      _tableScale = 1.0;
                                      if (_hBodyController.hasClients) _hBodyController.jumpTo(0);
                                      if (_vBodyController.hasClients) _vBodyController.jumpTo(0);
                                  });
                                  AnalyticsManager.logEvent('chart_zoom_reset', parameters: {'table_id': tid});
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 16),
                      // Row 2: Controls
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                           // Data Toggle (Left/Right)
                           if (_getConfig!.rMeasure.isNotEmpty || _getDataFromAPI.any((d) => d.datar.isNotEmpty && d.datar != "0"))
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
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
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: !_showDataR ? theme.primaryColor : Colors.transparent,
                                         borderRadius: BorderRadius.circular(16),
                                       ),
                                       child: Text(
                                         _getConfig!.lMeasure.isNotEmpty ? _getConfig!.lMeasure : "ชุดข้อมูล 1",
                                         style: TextStyle(fontSize: 10, color: !_showDataR ? Colors.white : Colors.grey[700]),
                                       ),
                                     ),
                                   ),
                                   InkWell(
                                     onTap: () => setState(() => _showDataR = true),
                                     child: Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: _showDataR ? theme.primaryColor : Colors.transparent,
                                         borderRadius: BorderRadius.circular(16),
                                       ),
                                       child: Text(
                                         _getConfig!.rMeasure.isNotEmpty ? _getConfig!.rMeasure : "ชุดข้อมูล 2",
                                         style: TextStyle(fontSize: 10, color: _showDataR ? Colors.white : Colors.grey[700]),
                                       ),
                                     ),
                                   ),
                                ],
                              ),
                            ),
                            
                            // Year Dropdown
                            if (_availableYears.isNotEmpty)
                              Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
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
                                      setState(() { _selectedYear = v; });
                                    },
                                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                                    isDense: true,
                                  ),
                                ),
                              ),

                            // Freq Dropdown (Updated)
                            getFreqWid(),
                        ],
                      )
                    ],
                  ),
               ),
               
               const SizedBox(height: 16),
               
               // 8.3.4 Description Area
               _buildInfoSection(theme, "คำนิยาม", _getConfig!.metaTerms),
               _buildInfoSection(theme, "หน่วยวัด", _getConfig!.metaMeasure),
               _buildInfoSection(theme, "แหล่งที่มา", _getConfig!.metaSource),
               _buildInfoSection(theme, "ติดต่อข้อมูลเพิ่มเติม", _getConfig!.metaUrl),
            ],
          ),
        ) 
        : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
