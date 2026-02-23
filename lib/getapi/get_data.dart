// To parse this JSON data, do
//
//     final getData = getDataFromJson(jsonString);

import 'dart:convert';

List<GetData> getDataFromJson(String str) =>
    List<GetData>.from(json.decode(str).map((x) => GetData.fromJson(x)));

String getDataToJson(List<GetData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetData {
  GetData({
    required this.branchId,
    required this.tableId,
    required this.tyear,
    required this.datar,
    required this.quater,
    required this.tmonth,
    required this.datal,
    required this.datal1,
    required this.datal2,
    required this.datal3,
    required this.datal4,
    required this.datal5,
    required this.datal6,
    required this.datal7,
    required this.datal8,
    required this.datal9,
    required this.datal10,
  });

  String branchId;
  String tableId;
  String tyear;
  String datar;
  String quater;
  String tmonth;
  String datal;
  String datal1;
  String datal2;
  String datal3;
  String datal4;
  String datal5;
  String datal6;
  String datal7;
  String datal8;
  String datal9;
  String datal10;

  List<String> get dataLList {
    if (datal.contains('|')) {
      return datal.split('|');
    }
    // Check if legacy fields have data (assuming "0" or empty means no data, but typically first field should be present)
    // Checking datal1 is enough usually.
    if (datal1.isNotEmpty && datal1 != "0") {
      return [datal1, datal2, datal3, datal4, datal5, datal6, datal7, datal8, datal9, datal10];
    }
    if (datal.isNotEmpty) {
      return [datal];
    }
    // Fallback for strict legacy where datal1 might be "0" but meaningful? Unlikely.
    // If all else fails, return legacy list anyway to be safe?
    return [datal1, datal2, datal3, datal4, datal5, datal6, datal7, datal8, datal9, datal10];
  }

  List<String> get dataRList {
    if (datar.contains('|')) {
      return datar.split('|');
    }
    if (datar.isNotEmpty) {
      return [datar];
    }
    return [];
  }

  factory GetData.fromJson(Map<String, dynamic> json) => GetData(
        branchId: json["branch_id"].toString(),
        tableId: json["table_id"].toString(),
        tyear: json["tyear"].toString(),
        datar: json["datar"].toString(),
        quater: json["quater"].toString(),
        tmonth: json["tmonth"].toString(),
        datal: json["datal"] == null ? "" : json["datal"].toString(),
        datal1: json["datal1"] == null ? "0" : json["datal1"].toString(),
        datal2: json["datal2"] == null ? "0" : json["datal2"].toString(),
        datal3: json["datal3"] == null ? "0" : json["datal3"].toString(),
        datal4: json["datal4"] == null ? "0" : json["datal4"].toString(),
        datal5: json["datal5"] == null ? "0" : json["datal5"].toString(),
        datal6: json["datal6"] == null ? "0" : json["datal6"].toString(),
        datal7: json["datal7"] == null ? "0" : json["datal7"].toString(),
        datal8: json["datal8"] == null ? "0" : json["datal8"].toString(),
        datal9: json["datal9"] == null ? "0" : json["datal9"].toString(),
        datal10: json["datal10"] == null ? "0" : json["datal10"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "table_id": tableId,
        "tyear": tyear,
        "datar": datar,
        "quater": quater,
        "tmonth": tmonth,
        "datal": datal,
        "datal1": datal1,
        "datal2": datal2,
        "datal3": datal3,
        "datal4": datal4,
        "datal5": datal5,
        "datal6": datal6,
        "datal7": datal7,
        "datal8": datal8,
        "datal9": datal9,
        "datal10": datal10,
      };
}
