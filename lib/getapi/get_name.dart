// To parse this JSON data, do
//
//     final getTableName = getTableNameFromJson(jsonString);

import 'dart:convert';

GetTableName getTableNameFromJson(String str) =>
    GetTableName.fromJson(json.decode(str));

String getTableNameToJson(GetTableName data) => json.encode(data.toJson());

class GetTableName {
  GetTableName({
    required this.tableName,
  });

  final String tableName;

  factory GetTableName.fromJson(Map<String, dynamic> json) => GetTableName(
        tableName: json["table_name"] == null ? "" : json["table_name"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "table_name": tableName == null ? null : tableName,
      };
}
