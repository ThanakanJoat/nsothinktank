import 'package:flutter/material.dart';
import 'build_inherited_widget.dart';
import 'freqmenu_class.dart';
import 'popmenu_class.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class PieChartPage extends StatefulWidget {
  const PieChartPage({Key? key}) : super(key: key);
  @override
  State createState() => _PieChartPageState();
}
// ... (skipping context for brevity in tool call, just targeting lines)
// wait, I need to do this carefully. I'll split into two replace calls or one big one if contiguous.
// They are not contiguous. Line 5 and 136.
// I'll do two calls. First add import.


class _PieChartPageState extends State<PieChartPage> {
  late AppPopupMenu<String> appMenu03;
  late AppPopupMenu<String> appMenu04;

  @override
  void initState() {
    super.initState();

    appMenu03 = MenuClass<String>(
        key: const Key('SubClass03'),
        onSelected: (String value) {
          InheritedData.of(appMenu03.context!)?.data = value;
          Navigator.pushReplacementNamed(context, '/checkbarchart',
              arguments: {'id': '102', 'sub_id': '$value'});
        });

    appMenu04 = FreqMenuClass<String>(
        key: const Key('SubClass04'),
        onSelected: (String value) {
          InheritedData.of(appMenu03.context!)?.data = value;
          Navigator.pushReplacementNamed(context, '/checkbarchart',
              arguments: {'id': '102', 'sub_id': '$value'});
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Assuming back button is handled or not needed on root of this page
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _buildMenuCard(
                 title: "ชุดข้อมูลที่ 1", 
                 description: "เลือกข้อมูลแรงงาน",
                 menu: appMenu03,
                 items: const [
                    PopupMenuItem(value: 'MA10201Y', child: Text('แรงงาน')),
                    PopupMenuItem(value: 'MA10202Y', child: Text('อัตราการว่างงาน')),
                    PopupMenuItem(value: 'MA10203Y', child: Text('กำลังแรงงาน')),
                 ]
               ),
               const SizedBox(height: 16),
               _buildMenuCard(
                 title: "ชุดข้อมูลที่ 2", 
                 description: "เลือกข้อมูลเพิ่มเติม",
                 menu: appMenu04,
                 items: const [
                    PopupMenuItem(value: 'MA10201Y', child: Text('แรงงาน xx')),
                    PopupMenuItem(value: 'MA10202Y', child: Text('อัตราการว่างงาน xx')),
                    PopupMenuItem(value: 'MA10203Y', child: Text('กำลังแรงงาน xx')),
                 ]
               ),
            ],
          ),
        ),
      ),
       bottomSheet: Container(
        height: kToolbarHeight + 20, 
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               InkWell(
                 onTap: () => Navigator.pushReplacementNamed(context, '/catalog'),
                   child: Row(
                     children: [
                       Icon(Icons.arrow_back_ios, color: theme.primaryColor),
                       Text("ย้อนกลับ", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                     ],
                   ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required String title, required String description, required AppPopupMenu menu, required List<PopupMenuItem<String>> items}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            menu.set(
              initialValue: '5',
              menuItems: items,
              elevation: 8,
              icon: Icon(Icons.arrow_drop_down_circle, color: Theme.of(context).primaryColor, size: 32),
              offset: const Offset(0, 45),
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
