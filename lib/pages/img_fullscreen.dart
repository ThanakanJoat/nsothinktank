import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  final String url;
  ImageScreen(this.url);

  @override
  _MyImageScreen createState() => _MyImageScreen(url);
}

class _MyImageScreen extends State<ImageScreen> {
  final String url;
  _MyImageScreen(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blue,
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          elevation: 4.0,
          centerTitle: true,
          title: new Text(
            "",
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
        ),
        body: Image.network(url, width: double.infinity));
  }
}
