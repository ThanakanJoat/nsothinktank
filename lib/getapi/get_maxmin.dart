// To parse this JSON data, do
//
//     final getMinMax = getMinMaxFromJson(jsonString);

import 'dart:convert';

GetMinMax getMinMaxFromJson(String str) => GetMinMax.fromJson(json.decode(str));

String getMinMaxToJson(GetMinMax data) => json.encode(data.toJson());

class GetMinMax {
  GetMinMax({
    required this.maxl,
    required this.minl,
  });

  final String maxl;
  final String minl;

  factory GetMinMax.fromJson(Map<String, dynamic> json) => GetMinMax(
        maxl: json["maxl"] == null ? "" : json["maxl"].toString(),
        minl: json["minl"] == null ? "" : json["minl"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "maxl": maxl == null ? null : maxl,
        "minl": minl == null ? null : minl,
      };
}
