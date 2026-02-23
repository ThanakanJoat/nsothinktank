import 'dart:convert';

List<GetDashboard> getDashboardFromJson(String str) =>
    List<GetDashboard>.from(json.decode(str).map((x) => GetDashboard.fromJson(x)));

class GetDashboard {
  String branchId;
  String tableId;
  String tableName;
  String unit;
  String unitLeft;
  String unitRight;
  String freq;
  String timestamp;
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
    required this.timestamp,
  });

  factory GetDashboard.fromJson(Map<String, dynamic> json) => GetDashboard(
        branchId: json["branch_id"]?.toString() ?? "",
        tableId: json["table_id"]?.toString() ?? "",
        tableName: json["table_name"]?.toString() ?? "",
        unit: json["unit"]?.toString() ?? "",
        unitLeft: json["unit_left"]?.toString() ?? "",
        unitRight: json["unit_right"]?.toString() ?? "",
        freq: json["freq"]?.toString() ?? "",
        timestamp: json["timestamp"]?.toString() ?? "",
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
