// To parse this JSON data, do
//
//     final getFreq = getFreqFromJson(jsonString);

import 'dart:convert';

List<GetFreq> getFreqFromJson(String str) =>
    List<GetFreq>.from(json.decode(str).map((x) => GetFreq.fromJson(x)));

String getFreqToJson(List<GetFreq> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetFreq {
  GetFreq({
    required this.freq,
    required this.freqName,
  });

  String freq;
  String freqName;

  factory GetFreq.fromJson(Map<String, dynamic> json) => GetFreq(
        freq: json["freq"] == null ? "" : json["freq"].toString(),
        freqName: json["freq_name"] == null ? "" : json["freq_name"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "freq": freq == null ? null : freq,
        "freq_name": freqName == null ? null : freqName,
      };
}
