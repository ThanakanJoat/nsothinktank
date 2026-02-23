// To parse this JSON data, do
//
//     final getTitle = getTitleFromJson(jsonString);

import 'dart:convert';

List<GetTitle> getTitleFromJson(String str) =>
    List<GetTitle>.from(json.decode(str).map((x) => GetTitle.fromJson(x)));

String getTitleToJson(List<GetTitle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTitle {
  GetTitle({
    required this.tableId,
    required this.tableName,
  });

  String tableId;
  String tableName;

  factory GetTitle.fromJson(Map<String, dynamic> json) => GetTitle(
        tableId: json["table_id"] == null ? "" : json["table_id"].toString(),
        tableName: json["table_name"] == null ? "" : json["table_name"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "table_id": tableId == null ? null : tableId,
        "table_name": tableName == null ? null : tableName,
      };
}
