import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class MadeeChatPage extends StatefulWidget {
  const MadeeChatPage({super.key});

  @override
  State<MadeeChatPage> createState() => _MadeeChatPageState();
}

class _MadeeChatPageState extends State<MadeeChatPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
             if (mounted) {
               setState(() {
                 _isLoading = false;
               });
             }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://www.nso.go.th/madeechat/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain), 
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
                     const SizedBox(width: 8),
                    Text(
                      "น้องมาดี",
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
