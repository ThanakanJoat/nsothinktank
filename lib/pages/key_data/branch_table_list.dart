import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/getapi/get_title.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';
import 'package:nsothinktank/utils/branch_icons.dart';

class BranchTableListPage extends StatefulWidget {
  const BranchTableListPage({Key? key}) : super(key: key);

  @override
  _BranchTableListPageState createState() => _BranchTableListPageState();
}

class _BranchTableListPageState extends State<BranchTableListPage> {
  List<GetTitle> _tables = [];
  bool _isLoading = true;
  String? _branchId;
  String? _branchTitle;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    _branchId = args['id'].toString();
    _branchTitle = args['title']?.toString() ?? 'รายการสถิติ';
    if (_tables.isEmpty) {
      _fetchTables();
    }
  }

  Future<void> _fetchTables() async {
    try {
      final url = Uri.parse('${baseURL}get_title.php?bid=$_branchId&tid=');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _tables = getTitleFromJson(response.body);
          _isLoading = false;
        });
        AnalyticsManager.logEvent('view_branch_tables', parameters: {
          'branch_id': _branchId,
          'branch_title': _branchTitle,
          'count': _tables.length
        });
      } else {
        setState(() {
          _error = "Server Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Connection Error: $e";
        _isLoading = false;
      });
      AnalyticsManager.logEvent('api_error', parameters: {
        'endpoint': 'get_title',
        'error': e.toString()
      });
    }
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
           onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png', width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: theme.primaryColor.withOpacity(0.1),
                       shape: BoxShape.circle
                     ),
                     child: Icon(BranchIcons.getIcon(_branchId ?? ''), color: theme.primaryColor),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(_branchTitle!, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                         Text("เลือกรายการสถิติที่คุณสนใจ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/chart_page', arguments: {
                                'id': _branchId,
                                'sub_id': table.tableId
                              });
                              AnalyticsManager.logEvent('view_table_from_list', parameters: {
                                'branch_id': _branchId,
                                'table_id': table.tableId,
                                'table_name': table.tableName
                              });
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Icon(BranchIcons.getIcon(_branchId ?? ''), color: theme.primaryColor, size: 24),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      table.tableName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                                ],
                              ),
                            ),
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
