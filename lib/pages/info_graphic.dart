// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_options.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:nsothinktank/getapi/info_graphic.dart';
// import 'package:nsothinktank/pages/img_fullscreen.dart';
// import 'package:http/http.dart' as http;

// // final List<String> imgList = [
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/98/covid_290164_1.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/97/info15-01-64-1.png',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/96/info15-01-64-2.png',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/95/The_drug_2563.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/94/lady_2563.png',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/93/2563_manage_gov_Info.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/92/2563_Net5G-Info.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/91/2563_ReformPlan-Info.jpg',
// //   'http://www.nso.go.th/sites/2014/DocLib16/info/info_1-63.png',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/89/2563_GovInfo-6M.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/89/2563_GovInfo-6M.jpg',
// //   'http://www.nso.go.th/sites/2014/Lists/Infographic/Attachments/88/Exclusive03-63.png'
// // ];

// class InfoGraphicPage extends StatefulWidget {
//   InfoGraphicPage({Key? key}) : super(key: key);

//   @override
//   _InfoGraphicPageState createState() => _InfoGraphicPageState();
// }

// class _InfoGraphicPageState extends State<InfoGraphicPage> {
//   late List<String> imgList;
//   late List<String> _imgList;
//   bool loadinfo = false;

//   @override
//   void initState() {
//     this.getInfo();
//     super.initState();
//   }

//   Future<void> getInfo() async {
//     var url = Uri.parse('https://thaistat.nso.go.th/api/info_graphic.php');
//     var response = await http.get(url);
//     setState(() {
//       imgList = infoGraphicFromJson(response.body);
//       loadinfo = true;
//     });
//     print(_imgList);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     Widget image_carousel;

//     image_carousel = FutureBuilder(
//         future: getInfo(),
//         builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//           if ((loadinfo)) {
//             image_carousel = new Container(
//                 child: CarouselSlider(
//               options: CarouselOptions(
//                   height: height * 0.7,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   aspectRatio: 2.0,
//                   onPageChanged: (index, reason) {
//                     setState(() {});
//                   }),
//               items: imgList.map((i) {
//                 return Builder(
//                   builder: (BuildContext context) {
//                     return Container(
//                         width: MediaQuery.of(context).size.width,
//                         margin: EdgeInsets.symmetric(horizontal: 5.0),
//                         decoration: BoxDecoration(color: Colors.amber),
//                         child: GestureDetector(
//                             child: InteractiveViewer(
//                               minScale: 1.0,
//                               maxScale: 5.0,
//                               child: Image.network(i, fit: BoxFit.fill),
//                             ),
//                             onTap: () {
//                               Navigator.push<Widget>(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ImageScreen(i),
//                                 ),
//                               );
//                             }));
//                   },
//                 );
//               }).toList(),
//             ));
//           } else {
//             image_carousel = new Container();
//           }
//           return image_carousel;
//         });

//     return MaterialApp(
//         theme: new ThemeData(
//           fontFamily: 'Prompt',
//         ),
//         home: new Scaffold(
//           appBar: new AppBar(
//             backgroundColor: Colors.blue,
//             scrolledUnderElevation: 4.0,
//             shadowColor: Theme.of(context).shadowColor,
//             elevation: 4.0,
//             centerTitle: true,
//             title: Row(
//               children: <Widget>[
//                 new Image.asset('assets/images/nso.png',
//                     width: 52, height: 52, fit: BoxFit.fill),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 30),
//                   child: new Text(
//                     "สำนักงานสถิติแห่งชาติ",
//                     style: new TextStyle(
//                         fontWeight: FontWeight.normal,
//                         fontSize: 22,
//                         color: Colors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//             automaticallyImplyLeading: false,
//           ),
//           body: Center(
//             child: Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Center(
//                         child: new Text(
//                           "Infographic",
//                           style: new TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(children: [
//                   image_carousel,
//                 ]),
//               ],
//             ),
//           ),
//           bottomSheet: Container(
//             height: kToolbarHeight,
//             child: Column(
//               children: [
//                 GestureDetector(
//                   child: new AppBar(
//                     backgroundColor: Colors.blue,
//                     centerTitle: true,
//                     title: Row(
//                       children: <Widget>[
//                         new GestureDetector(
//                           onTap: () {
//                             Navigator.pushReplacementNamed(context, '/home');
//                           },
//                           child: new Image.asset('assets/images/back.png',
//                               width: 48, height: 48, fit: BoxFit.fill),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.75,
//                         ),
//                       ],
//                     ),
//                     automaticallyImplyLeading: false,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class InfoGraphicPage extends StatefulWidget {
  const InfoGraphicPage({super.key});

  @override
  State<InfoGraphicPage> createState() => _InfoGraphicPageState();
}

class _InfoGraphicPageState extends State<InfoGraphicPage> {
  List<String> imgList = [];
  bool loadinfo = false;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'infographic'});
    getInfo();
  }

  Future<void> getInfo() async {
    var url = Uri.parse('https://thaistat.nso.go.th/api/info_graphic.php');
    try {
      var response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        setState(() {
          if (decoded is List) {
             imgList = List<String>.from(decoded);
          }
          loadinfo = true;
        });
      } else {
        throw Exception("Failed to load images: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading images: $e");
      if (mounted) {
        setState(() {
          loadinfo = false;
        });
      }
    }
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.insert_chart, color: theme.primaryColor),
                   const SizedBox(width: 8),
                  Text(
                    "Infographic",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Carousel
            Expanded(
              child: loadinfo && imgList.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: height * 0.6,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.85,
                            aspectRatio: 16/9,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            },
                          ),
                          items: imgList.map((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                      image: DecorationImage(
                                        image: ResizeImage(NetworkImage(url), width: 1080),
                                        fit: BoxFit.contain,
                                      )
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageScreen(url),
                                        ),

                                      );
                                      AnalyticsManager.logEvent('view_infographic_fullscreen', parameters: {'url': url});
                                    },
                                    child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16))), // Ripple effect container
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("แตะที่รูปเพื่อขยาย", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imgList.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : theme.primaryColor)
                                    .withOpacity(_current == entry.key ? 0.9 : 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : loadinfo && imgList.isEmpty 
                      ? Center(child: Text("ไม่พบข้อมูล Infographic", style: theme.textTheme.bodyLarge))
                      : Center(child: CircularProgressIndicator(color: theme.primaryColor)),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imageUrl;

  const ImageScreen(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Infographic", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
      ),
    );
  }
}

