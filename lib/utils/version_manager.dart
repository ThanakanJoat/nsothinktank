import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/getapi/get_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter/material.dart';

class VersionManager {
  static GetVersion? _remoteData;

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getBuildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  static void openAppStore() {
    OpenStore.instance.open(
      appStoreId: _remoteData?.iosPackage ?? '1601704222', 
      androidAppBundleId: _remoteData?.androidPackage ?? 'th.go.nso.nsothinktank', 
    );
  }

  static Future<bool> isUpdateAvailable() async {
    try {
      final response = await http.get(Uri.parse('${baseURL}get_version.php'));
      if (response.statusCode == 200) {
        _remoteData = getVersionFromJson(response.body); // Cache the remote data
        final localVersion = await getAppVersion();
        
        if (_remoteData != null) {
          String remoteVersion = Platform.isAndroid ? _remoteData!.androidVersion : _remoteData!.iosVersion;
          return _shouldUpdate(localVersion, remoteVersion);
        }
      }
    } catch (e) {
      print("Error checking version: $e");
    }
    return false;
  }

  static bool _shouldUpdate(String local, String server) {
    try {
      List<String> localParts = local.split('.');
      List<String> serverParts = server.split('.');
      
      int length = localParts.length > serverParts.length ? localParts.length : serverParts.length;
      
      for (int i = 0; i < length; i++) {
        int l = i < localParts.length ? int.parse(localParts[i]) : 0;
        int s = i < serverParts.length ? int.parse(serverParts[i]) : 0; // Treat missing as 0
        
        if (s > l) return true;
        if (s < l) return false;
      }
    } catch (e) {
      // Fallback to string compare if parsing fails
      return server.compareTo(local) > 0;
    }
    return false;
  }

  static Future<void> showUpdateDialog(BuildContext context, {bool allowSkip = true, VoidCallback? onSkip}) async {
    String version = await getAppVersion();
    showDialog(
      context: context,
      barrierDismissible: allowSkip,
      builder: (context) => AlertDialog(
        title: const Text("มีเวอร์ชันใหม่"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("เวอร์ชันปัจจุบัน: $version"),
            const SizedBox(height: 10),
            const Text("กรุณาอัปเดตแอปพลิเคชันเป็นเวอร์ชันล่าสุดเพื่อประสิทธิภาพการทำงานที่ดีที่สุด"),
          ],
        ),
        actions: [
          if (allowSkip)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onSkip != null) onSkip();
              },
              child: const Text("ไว้ทีหลัง", style: TextStyle(color: Colors.grey)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppStore();
              if (onSkip != null) onSkip(); // In splash screen, we might want to continue or just close. Actually, usually openStore just opens URL. 
              // If forced, we shouldn't skip. But user said "warning", usually implies optional?
              // I will assume allowSkip=true by default for now unless specified.
            },
            child: const Text("อัปเดตตอนนี้"),
          ),
        ],
      ),
    );
  }
}
