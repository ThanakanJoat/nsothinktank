// To parse this JSON data, do
//
//     final getVersion = getVersionFromJson(jsonString);

import 'dart:convert';

GetVersion getVersionFromJson(String str) =>
    GetVersion.fromJson(json.decode(str));

String getVersionToJson(GetVersion data) => json.encode(data.toJson());

class GetVersion {
  GetVersion({
    required this.androidPackage,
    required this.androidVersion,
    required this.iosPackage,
    required this.iosVersion,
  });

  String androidPackage;
  String androidVersion;
  String iosPackage;
  String iosVersion;

  factory GetVersion.fromJson(Map<String, dynamic> json) => GetVersion(
        androidPackage: json["android_package"],
        androidVersion: json["android_version"],
        iosPackage: json["ios_package"],
        iosVersion: json["ios_version"],
      );

  Map<String, dynamic> toJson() => {
        "android_package": androidPackage,
        "android_version": androidVersion,
        "ios_package": iosPackage,
        "ios_version": iosVersion,
      };
}
