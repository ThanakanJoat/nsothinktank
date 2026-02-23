// To parse this JSON data, do
//
//     final getConfig = getConfigFromJson(jsonString);

import 'dart:convert';

GetConfig getConfigFromJson(String str) => GetConfig.fromJson(json.decode(str));

String getConfigToJson(GetConfig data) => json.encode(data.toJson());

class GetConfig {
  GetConfig({
    required this.tableName,
    required this.cname,
    required this.lMeasure,
    required this.rMeasure,
    required this.graphPie,
    required this.graphLine,
    required this.graphBar,
    required this.metaOs,
    required this.metaTerms,
    required this.metaMeasure,
    required this.metaSource,
    required this.metaUrl,
    required this.measure,
    required this.cname1,
    required this.cname2,
    required this.cname3,
    required this.cname4,
    required this.cname5,
    required this.cname6,
    required this.cname7,
    required this.cname8,
    required this.cname9,
    required this.cname10,
  });

  final String tableName;
  final String cname;
  final String lMeasure;
  final String rMeasure;
  final String graphPie;
  final String graphLine;
  final String graphBar;
  final String metaOs;
  final String metaTerms;
  final String metaMeasure;
  final String metaSource;
  final String metaUrl;
  final String measure;
  final String cname1;
  final String cname2;
  final String cname3;
  final String cname4;
  final String cname5;
  final String cname6;
  final String cname7;
  final String cname8;
  final String cname9;
  final String cname10;

  List<String> get columnNames {
    if (cname.isNotEmpty) {
      return cname.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    List<String> list = [];
    if (cname1.isNotEmpty) list.add(cname1);
    if (cname2.isNotEmpty) list.add(cname2);
    if (cname3.isNotEmpty) list.add(cname3);
    if (cname4.isNotEmpty) list.add(cname4);
    if (cname5.isNotEmpty) list.add(cname5);
    if (cname6.isNotEmpty) list.add(cname6);
    if (cname7.isNotEmpty) list.add(cname7);
    if (cname8.isNotEmpty) list.add(cname8);
    if (cname9.isNotEmpty) list.add(cname9);
    if (cname10.isNotEmpty) list.add(cname10);
    return list;
  }

  factory GetConfig.fromJson(Map<String, dynamic> json) => GetConfig(
        tableName: json["table_name"] == null ? "" : json["table_name"].toString(),
        cname: json["c_name"] == null ? "" : json["c_name"].toString(),
        lMeasure: json["l_measure"] == null ? "" : json["l_measure"].toString(),
        rMeasure: json["r_measure"] == null ? "" : json["r_measure"].toString(),
        measure: json["measure"] == null ? "" : json["measure"].toString(),
        graphPie: json["graph_pie"] == null ? "0" : json["graph_pie"].toString(),
        graphLine: json["graph_line"] == null ? "0" : json["graph_line"].toString(),
        graphBar: json["graph_bar"] == null ? "0" : json["graph_bar"].toString(),
        metaOs: json["meta_os"] == null ? "" : json["meta_os"].toString(),
        metaTerms: json["meta_terms"] == null ? "" : json["meta_terms"].toString(),
        metaMeasure: json["meta_measure"] == null ? "" : json["meta_measure"].toString(),
        metaSource: json["meta_source"] == null ? "" : json["meta_source"].toString(),
        metaUrl: json["meta_url"] == null ? "" : json["meta_url"].toString(),
        cname1: json["cname1"] == null ? "" : json["cname1"].toString(),
        cname2: json["cname2"] == null ? "" : json["cname2"].toString(),
        cname3: json["cname3"] == null ? "" : json["cname3"].toString(),
        cname4: json["cname4"] == null ? "" : json["cname4"].toString(),
        cname5: json["cname5"] == null ? "" : json["cname5"].toString(),
        cname6: json["cname6"] == null ? "" : json["cname6"].toString(),
        cname7: json["cname7"] == null ? "" : json["cname7"].toString(),
        cname8: json["cname8"] == null ? "" : json["cname8"].toString(),
        cname9: json["cname9"] == null ? "" : json["cname9"].toString(),
        cname10: json["cname10"] == null ? "" : json["cname10"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "table_name": tableName,
        "c_name": cname,
        "l_measure": lMeasure,
        "r_measure": rMeasure,
        "measure": measure,
        "graph_pie": graphPie,
        "graph_line": graphLine,
        "graph_bar": graphBar,
        "meta_os": metaOs,
        "meta_terms": metaTerms,
        "meta_measure": metaMeasure,
        "meta_source": metaSource,
        "meta_url": metaUrl,
        "cname1": cname1,
        "cname2": cname2,
        "cname3": cname3,
        "cname4": cname4,
        "cname5": cname5,
        "cname6": cname6,
        "cname7": cname7,
        "cname8": cname8,
        "cname9": cname9,
        "cname10": cname10,
      };
}
