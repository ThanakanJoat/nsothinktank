import 'package:flutter/material.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/getapi/get_config.dart';
import 'package:nsothinktank/pages/key_data/catalog_list.dart';
import 'package:nsothinktank/pages/key_data/pages/chart_page.dart';
import 'package:nsothinktank/pages/key_data/pages/line_chart.dart';
import 'package:nsothinktank/pages/main_page.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late GetConfig _getConfig;
  bool loadconfig = false;


  final List<Map<String, dynamic>> categories = [
    {'id': cat_id1, 'sub_id': sub_id1, 'image': 'assets/images/cat1.png', 'title': "ประชากร"},
    {'id': cat_id2, 'sub_id': sub_id2, 'image': 'assets/images/cat2.png', 'title': "แรงงาน"},
    {'id': cat_id3, 'sub_id': sub_id3, 'image': 'assets/images/cat3.png', 'title': "การศึกษา"},
    {'id': cat_id4, 'sub_id': sub_id4, 'image': 'assets/images/cat4.png', 'title': "ศาสนา"},
    {'id': cat_id5, 'sub_id': sub_id5, 'image': 'assets/images/cat5.png', 'title': "สุขภาพ"},
    {'id': cat_id6, 'sub_id': sub_id6, 'image': 'assets/images/cat6.png', 'title': "สวัสดิการสังคม"},
    {'id': cat_id7, 'sub_id': sub_id7, 'image': 'assets/images/cat7.png', 'title': "หญิงและชาย"},
    {'id': cat_id8, 'sub_id': sub_id8, 'image': 'assets/images/cat8.png', 'title': "รายได้และรายจ่ายของครัวเรือน"},
    {'id': cat_id9, 'sub_id': sub_id9, 'image': 'assets/images/cat9.png', 'title': "ยุติธรรม ความมั่นคง การเมือง และการปกครอง"},
    {'id': cat_id10, 'sub_id': sub_id10, 'image': 'assets/images/cat10.png', 'title': "บัญชีประชาชาติ"},
    {'id': cat_id11, 'sub_id': sub_id11, 'image': 'assets/images/cat11.png', 'title': "เกษตรและประมง"},
    {'id': cat_id12, 'sub_id': sub_id12, 'image': 'assets/images/cat12.png', 'title': "อุตสาหกรรม"},
    {'id': cat_id13, 'sub_id': sub_id13, 'image': 'assets/images/cat13.png', 'title': "พลังงาน"},
    {'id': cat_id14, 'sub_id': sub_id14, 'image': 'assets/images/cat14.png', 'title': "การค้าและราคา"},
    {'id': cat_id15, 'sub_id': sub_id15, 'image': 'assets/images/cat15.png', 'title': "ขนส่งและโลจิสติกส์"},
    {'id': cat_id16, 'sub_id': sub_id16, 'image': 'assets/images/cat16.png', 'title': "เทคโนโลยีสารสนเทศและการสื่อสาร"},
    {'id': cat_id17, 'sub_id': sub_id17, 'image': 'assets/images/cat17.png', 'title': "การท่องเที่ยวและกีฬา"},
    {'id': cat_id18, 'sub_id': sub_id18, 'image': 'assets/images/cat18.png', 'title': "การเงิน การธนาคาร และการประกันภัย"},
    {'id': cat_id19, 'sub_id': sub_id19, 'image': 'assets/images/cat19.png', 'title': "การคลัง"},
    {'id': cat_id20, 'sub_id': sub_id20, 'image': 'assets/images/cat20.png', 'title': "วิทยาศาสตร์ เทคโนโลยี และนวัตกรรม"},
    {'id': cat_id21, 'sub_id': sub_id21, 'image': 'assets/images/cat21.png', 'title': "ทรัพยากรธรรมชาติและสิ่งแวดล้อม"},
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.logEvent('view_page', parameters: {'page_name': 'catalog_grid'});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).primaryColor == Colors.blue ? AppTheme.lightTheme : Theme.of(context);
    
    // Responsive aspect ratio calculation
    double screenWidth = MediaQuery.of(context).size.width;
    double textScale = MediaQuery.of(context).textScaleFactor;
    
    // Dynamic dimensions based on screen width
    // Pixel 9 (approx 412 width) -> font size ~17
    // Small phone (360 width) -> font size ~15
    double dynamicFontSize = (screenWidth / 24).clamp(14.0, 18.0);
    double dynamicIconSize = (screenWidth / 14).clamp(24.0, 32.0);
    
    double itemWidth = (screenWidth - 48) / 2; // (Screen - Padding(16*2) - Spacing(16)) / 2
    
    // Calculate base height needed for content:
    // Icon + Spacing + Text(4 lines) + Padding
    double baseHeight = dynamicIconSize + 8 + (4 * dynamicFontSize * 1.2) + 24; 
    
    // Adjust for text scale from user settings
    double desiredHeight = baseHeight * (textScale > 1.0 ? textScale : 1.0);
    
    // Ensure height is not too small relative to width (for aesthetics on wide screens)
    if (desiredHeight < 160) desiredHeight = 160;

    double aspectRatio = itemWidth / desiredHeight;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain), // Reduced size
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
        actions: [
          IconButton(
             icon: const Icon(Icons.list, color: Colors.white),
             tooltip: "List View",
             onPressed: () => Navigator.pushReplacementNamed(context, '/cataloglist'),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.grid_view_rounded, color: AppTheme.primaryColor),
                   const SizedBox(width: 8),
                  Text(
                    "หมวดหมู่สถิติ",
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  // Vibrant colors for cards
                  final List<Color> cardColors = [
                    Colors.blue, Colors.orange, Colors.purple, Colors.green, 
                    Colors.red, Colors.teal, Colors.indigo, Colors.brown,
                    Colors.pink, Colors.deepPurple
                  ];
                  final Color itemColor = cardColors[index % cardColors.length];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: itemColor.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: itemColor.withOpacity(0.1), width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/branch_tables', arguments: {
                            'id': item['id'],
                            'title': item['title']
                          });
                          AnalyticsManager.logEvent('view_branch', parameters: {
                            'branch_id': item['id'],
                            'title': item['title']
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                             // Background Faded Icon (Bottom Right)
                             Positioned(
                               right: -15,
                               bottom: -15,
                               child: Opacity(
                                 opacity: 0.1,
                                 child: Image.asset(item['image'], width: 100, height: 100, fit: BoxFit.contain), 
                               ),
                             ),
                             Positioned.fill(
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     // Small Icon Top Left
                                     Container(
                                       padding: const EdgeInsets.all(8),
                                       decoration: BoxDecoration(
                                         color: itemColor.withOpacity(0.1),
                                         shape: BoxShape.circle,
                                       ),
                                       child: Image.asset(item['image'], width: dynamicIconSize, height: dynamicIconSize, fit: BoxFit.contain), 
                                     ),
                                     const SizedBox(height: 8), // Increased spacing
                                     // Title below icon
                                     Expanded(
                                       child: Text(
                                         item['title'].replaceAll('\n', ' '), 
                                         style: TextStyle( // Changed from const
                                           fontWeight: FontWeight.bold, 
                                           fontSize: dynamicFontSize, 
                                           color: Colors.black87,
                                           height: 1.2
                                         ),
                                         maxLines: 4,
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
