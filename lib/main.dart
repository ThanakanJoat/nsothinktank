import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nsothinktank/overrides.dart';
import 'package:nsothinktank/routers.dart';
import 'package:nsothinktank/theme/app_theme.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: routes,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
