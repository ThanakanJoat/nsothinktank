// To parse this JSON data, do
//
//     final calendar = calendarFromJson(jsonString);

import 'dart:convert';

List<String> calendarFromJson(String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String calendarToJson(List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));
