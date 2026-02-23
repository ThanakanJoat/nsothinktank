import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/overrides.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class ContactUsWebPage extends StatefulWidget {
  const ContactUsWebPage({super.key});

  @override
  State<ContactUsWebPage> createState() => _ContactUsWebPageState();
}

class _ContactUsWebPageState extends State<ContactUsWebPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(contact_url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectJavaScript();
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
      );

    HttpOverrides.global = MyHttpOverrides();
  }

  void _injectJavaScript() {
    controller.runJavaScript('''
      (function() {
        // Hide all sections with class 'container mt-5 py-5'
        var mt5Sections = document.querySelectorAll('section.container.mt-5.py-5');
        for (var i = 0; i < mt5Sections.length; i++) {
          mt5Sections[i].style.display = 'none';
        }

        // Select the section with class 'container py-5' under 'main.contact'
        var mainContact = document.querySelector('main.contact');
        if (mainContact) {
          var py5Section = mainContact.querySelector('section.container.py-5');
          if (py5Section) {
            document.body.innerHTML = '';
            document.body.appendChild(py5Section);

            // Append all external scripts, iframes, and modals back to the body
            var scripts = document.querySelectorAll('script[src]');
            scripts.forEach(function(script) {
              var newScript = document.createElement('script');
              Array.from(script.attributes).forEach(attr => newScript.setAttribute(attr.name, attr.value));
              document.body.appendChild(newScript);
            });

            var iframes = document.querySelectorAll('iframe');
            iframes.forEach(function(iframe) {
              var newIframe = document.createElement('iframe');
              Array.from(iframe.attributes).forEach(attr => newIframe.setAttribute(attr.name, attr.value));
              document.body.appendChild(newIframe);
            });

            var modals = document.querySelectorAll('.modal');
            modals.forEach(function(modal) {
              document.body.appendChild(modal);
            });
          }
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
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
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.web, color: theme.primaryColor),
                   const SizedBox(width: 8),
                  Text(
                    "ติดต่อ สสช.",
                    style: theme.textTheme.headlineSmall?.copyWith(
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (cert, host, port) => true;
  }
}
