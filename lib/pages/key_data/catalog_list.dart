import 'package:flutter/material.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/pages/main_page.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:nsothinktank/utils/analytics_manager.dart';

class CatalogItem {
  final String id;
  final String subId;
  final String title;
  final String imagePath;

  CatalogItem(this.id, this.subId, this.title, this.imagePath);
}

class CatalogListPage extends StatefulWidget {
  const CatalogListPage({Key? key}) : super(key: key);

  @override
  _CatalogListPageState createState() => _CatalogListPageState();
}

class _CatalogListPageState extends State<CatalogListPage> {

  final List<CatalogItem> items = [
    CatalogItem(cat_id1, sub_id1, 'ประชากร', 'assets/images/cat1.png'),
    CatalogItem(cat_id2, sub_id2, 'แรงงาน', 'assets/images/cat2.png'),
    CatalogItem(cat_id3, sub_id3, 'การศึกษา', 'assets/images/cat3.png'),
    CatalogItem(cat_id4, sub_id4, 'ศาสนา ศิลปะ และวัฒนธรรม', 'assets/images/cat4.png'),
    CatalogItem(cat_id5, sub_id5, 'สุขภาพ', 'assets/images/cat5.png'),
    CatalogItem(cat_id6, sub_id6, 'สวัสดิการสังคม', 'assets/images/cat6.png'),
    CatalogItem(cat_id7, sub_id7, 'หญิงและชาย', 'assets/images/cat7.png'),
    CatalogItem(cat_id8, sub_id8, 'รายได้และรายจ่ายของครัวเรือน', 'assets/images/cat8.png'),
    CatalogItem(cat_id9, sub_id9, 'ยุติธรรมความมั่นคงการเมืองและการปกครอง', 'assets/images/cat9.png'),
    CatalogItem(cat_id10, sub_id10, 'บัญชีประชาชาติ', 'assets/images/cat10.png'),
    CatalogItem(cat_id11, sub_id11, 'เกษตรและประมง', 'assets/images/cat11.png'),
    CatalogItem(cat_id12, sub_id12, 'อุตสาหกรรม', 'assets/images/cat12.png'),
    CatalogItem(cat_id13, sub_id13, 'พลังงาน', 'assets/images/cat13.png'),
    CatalogItem(cat_id14, sub_id14, 'การค้าและราคา', 'assets/images/cat14.png'),
    CatalogItem(cat_id15, sub_id15, 'ขนส่งและโลจิสติกส์', 'assets/images/cat15.png'),
    CatalogItem(cat_id16, sub_id16, 'เทคโนโลยีสารสนเทศและการสื่อสาร', 'assets/images/cat16.png'),
    CatalogItem(cat_id17, sub_id17, 'การท่องเที่ยวและกีฬา', 'assets/images/cat17.png'),
    CatalogItem(cat_id18, sub_id18, 'การเงิน การธนาคาร และการประกันภัย', 'assets/images/cat18.png'),
    CatalogItem(cat_id19, sub_id19, 'การคลัง', 'assets/images/cat19.png'),
    CatalogItem(cat_id20, sub_id20, 'วิทยาศาสตร์ เทคโนโลยี และนวัตกรรม', 'assets/images/cat20.png'),
    CatalogItem(cat_id21, sub_id21, 'ทรัพยากรธรรมชาติและสิ่งแวดล้อม', 'assets/images/cat21.png'),
  ];

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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain), // Reduced size
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            tooltip: "Grid View",
             onPressed: () => Navigator.pushReplacementNamed(context, '/catalog'),
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
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.list, color: AppTheme.primaryColor),
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
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Vibrant colors for cards
                  final List<Color> cardColors = [
                    Colors.blue, Colors.orange, Colors.purple, Colors.green, 
                    Colors.red, Colors.teal, Colors.indigo, Colors.brown,
                    Colors.pink, Colors.deepPurple
                  ];
                  final Color itemColor = cardColors[index % cardColors.length];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: itemColor.withOpacity(0.2))),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                         Navigator.pushNamed(
                              context, '/branch_tables', 
                              arguments: {
                                 'id': item.id,
                                 'title': item.title
                              }
                          );
                          AnalyticsManager.logEvent('view_branch', parameters: {
                            'branch_id': item.id,
                            'title': item.title
                          });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: itemColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
