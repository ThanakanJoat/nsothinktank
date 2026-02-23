import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/overrides.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class ProvinceInfoPage extends StatefulWidget {
  const ProvinceInfoPage({super.key});

  @override
  State<ProvinceInfoPage> createState() => _ProvinceInfoPageState();
}

class _ProvinceInfoPageState extends State<ProvinceInfoPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
               isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(province_info_url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/province'),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(width: 8),
             Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "สำนักงานสถิติแห่งชาติ",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: "หน้าหลัก",
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "เกี่ยวกับข้อมูลจังหวัด",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
                   if (isLoading)
                    Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
