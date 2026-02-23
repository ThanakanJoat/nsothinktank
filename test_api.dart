
// ... imports and classes same as above ...
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ... (Use previous classes) ...
class GetDashboard {
  String branchId;
  String tableId;
  String tableName;
  String unit;
  String unitLeft;
  String unitRight;
  String freq;
  List<String> columns;
  List<DashboardRecord> records;

  GetDashboard({
    required this.branchId,
    required this.tableId,
    required this.tableName,
    required this.unit,
    required this.unitLeft,
    required this.unitRight,
    required this.freq,
    required this.columns,
    required this.records,
  });

  factory GetDashboard.fromJson(Map<String, dynamic> json) => GetDashboard(
        branchId: json["branch_id"]?.toString() ?? "",
        tableId: json["table_id"]?.toString() ?? "",
        tableName: json["table_name"]?.toString() ?? "",
        unit: json["unit"]?.toString() ?? "",
        unitLeft: json["unit_left"]?.toString() ?? "",
        unitRight: json["unit_right"]?.toString() ?? "",
        freq: json["freq"]?.toString() ?? "",
        columns: json["columns"] == null ? [] : List<String>.from(json["columns"].map((x) => x.toString())),
        records: json["records"] == null 
            ? [] 
            : List<DashboardRecord>.from(
                json["records"].map((x) => DashboardRecord.fromJson(x))),
      );
}

class DashboardRecord {
  String branchId;
  String tableId;
  String tyear;
  String datal;
  String datar;
  String quater;
  String tmonth;
  String periodLabel;
  int seq;
  List<String> datalValues;
  List<String> datarValues;

  DashboardRecord({
    required this.branchId,
    required this.tableId,
    required this.tyear,
    required this.datal,
    required this.datar,
    required this.quater,
    required this.tmonth,
    required this.periodLabel,
    required this.seq,
    required this.datalValues,
    required this.datarValues,
  });

  factory DashboardRecord.fromJson(Map<String, dynamic> json) => DashboardRecord(
        branchId: json["branch_id"]?.toString() ?? "",
        tableId: json["table_id"]?.toString() ?? "",
        tyear: json["tyear"]?.toString() ?? "",
        datal: json["datal"]?.toString() ?? "",
        datar: json["datar"]?.toString() ?? "",
        quater: json["quater"]?.toString() ?? "",
        tmonth: json["tmonth"]?.toString() ?? "",
        periodLabel: json["period_label"]?.toString() ?? "",
        seq: json["seq"] is int ? json["seq"] : int.tryParse(json["seq"]?.toString() ?? "0") ?? 0,
        datalValues: json["datal_values"] == null ? [] : List<String>.from(json["datal_values"].map((x) => x.toString())),
        datarValues: json["datar_values"] == null ? [] : List<String>.from(json["datar_values"].map((x) => x.toString())),
      );
}

List<GetDashboard> getDashboardFromJson(String str) =>
    List<GetDashboard>.from(json.decode(str).map((x) => GetDashboard.fromJson(x)));

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

void main() async {
  try {
    var url = Uri.parse('https://thaistat.nso.go.th/api/get_dashboard.php');
    var response = await http.get(url);
    if (response.statusCode == 200) {
       List<GetDashboard> items = getDashboardFromJson(response.body);
       for(var item in items.take(10)) {
           if (item.records.isEmpty) continue;
           
           item.records.sort((a, b) => a.seq.compareTo(b.seq));
           var last = item.records.last;
           
           bool useLeft = last.datal.isNotEmpty;
           String rawVal = useLeft ? last.datal : last.datar;
           
           // Logic check
           double total = _parseDataValue(rawVal);
           print("Item: ${item.tableName}, Raw: $rawVal, Total: $total");
       }
    }
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
