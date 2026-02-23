// To parse this JSON data, do
//
//     final getHtml = getHtmlFromJson(jsonString);

import 'dart:convert';

GetHtml getHtmlFromJson(String str) => GetHtml.fromJson(json.decode(str));

String getHtmlToJson(GetHtml data) => json.encode(data.toJson());

class GetHtml {
  GetHtml({
    required this.html,
  });

  final String html;

  factory GetHtml.fromJson(Map<String, dynamic> json) => GetHtml(
        html: json["html"] == null ? null : json["html"],
      );

  Map<String, dynamic> toJson() => {
        "html": html == null ? null : html,
      };
}
