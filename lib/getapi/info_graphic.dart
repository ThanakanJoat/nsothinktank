// To parse this JSON data, do
//
//     final infoGraphic = infoGraphicFromJson(jsonString);

import 'dart:convert';

List<String> infoGraphicFromJson(String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String infoGraphicToJson(List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));
