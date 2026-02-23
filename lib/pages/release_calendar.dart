import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/overrides.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = MyHttpOverrides();
    AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'release_calendar'});

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Optional: Inject JS to clean up page if needed
             // controller.runJavaScriptReturningResult('...'); 
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(calendar_url));
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
                  Icon(Icons.calendar_month, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "ปฏิทินการเผยแพร่ข้อมูล",
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
                   // Use WebViewWidget properly if controller is initialized
                   WebViewWidget(controller: controller),
                  if (_isLoading)
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
