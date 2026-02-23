import 'package:flutter/material.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({Key? key}) : super(key: key);

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
          children: [
            Image.asset('assets/images/nso.png',
                width: 32, height: 32, fit: BoxFit.contain),
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
        automaticallyImplyLeading: false,
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.menu_book, color: theme.primaryColor),
                       const SizedBox(width: 8),
                      Text(
                        "คู่มือการใช้งาน",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildManualCard(
                    context, 
                    theme,
                    title: "หน้าหลัก (Home)",
                    description: "หน้าหลักแสดงข้อมูลไฮไลท์สำคัญ (Dashboard) ท่านสามารถปัดซ้าย-ขวาเพื่อดูเรื่องน่าสนใจต่างๆ และกด 'ดูเพิ่มเติม' เพื่อดูกราฟรายละเอียด",
                    icon: Icons.home
                  ),
                  _buildManualCard(
                    context, 
                    theme,
                    title: "การค้นหาข้อมูล",
                    description: "ท่านสามารถค้นหาข้อมูลสถิติที่ต้องการได้ที่ช่องค้นหา โดยพิมพ์คำสำคัญ เช่น 'ประชากร', 'แรงงาน' หรือชื่อหมวดหมู่สถิติ ระบบจะแสดงตารางข้อมูลที่เกี่ยวข้อง",
                    icon: Icons.search
                  ),
                   _buildManualCard(
                    context, 
                    theme,
                    title: "การใช้งานหน้าข้อมูล (Chart Page)",
                    description: "ในหน้ารายละเอียดข้อมูล ท่านสามารถใช้งานฟังก์ชันต่างๆ:\n• ประเภทกราฟ: เปลี่ยนรูปแบบแสดงผล (กราฟแท่ง, กราฟเส้น, กราฟวงกลม, ตาราง) ได้จากแถบเครื่องมือ\n• ตารางข้อมูล: สามารถย่อ/ขยาย (Zoom) และเลื่อน (Pan) ตารางได้อิสระ โดยการใช้นิ้วถ่าง/หุบ หรือลากบนหน้าจอ\n• ความถี่/ปี: เลือกช่วงเวลาและความถี่ข้อมูลจากเมนูตัวเลือก\n• รีเซ็ต: กดปุ่มรีเซ็ต (ลูกศรวน) เพื่อคืนค่าการซูมทั้งกราฟและตารางสู่ปกติ",
                    icon: Icons.analytics
                  ),
                  _buildManualCard(
                    context, 
                    theme,
                    title: "การติดตามและแจ้งเตือน",
                    description: "กดปุ่มรูปกระดิ่งที่มุมขวาบนในหน้าข้อมูล เพื่อติดตามความเคลื่อนไหว\n• เมื่อข้อมูลมีการอัปเดต ระบบจะแจ้งเตือนผ่านกระดิ่งที่หน้าหลัก (สีส้ม)\n• กดที่กระดิ่งหน้าหลักเพื่อดูรายการรอการอัปเดต",
                    icon: Icons.notifications_active
                  ),
                  _buildManualCard(
                    context, 
                    theme,
                    title: "การบันทึกรายการโปรด (Bookmark)",
                    description: "กดปุ่ม Bookmark (รูปที่คั่นหนังสือ) ที่มุมขวาบนในหน้าข้อมูล เพื่อเก็บรายการที่ใช้งานบ่อยไว้ ท่านสามารถเปิดดูได้จากเมนู 'บันทึก' ที่แถบด้านล่างของหน้าหลัก",
                    icon: Icons.bookmark
                  ),
                   _buildManualCard(
                    context, 
                    theme,
                    title: "น้องมาดี (AI Chatbot)", 
                    description: "น้องมาดีคือผู้ช่วย AI อัจฉริยะที่คอยตอบคำถามและค้นหาข้อมูลสถิติให้กับท่านได้ทันที ง่ายๆ เพียงพิมพ์คำถามหรือหัวข้อที่ต้องการ น้องมาดีจะช่วยสรุปและแนะนำข้อมูลที่เกี่ยวข้องจากฐานข้อมูลขนาดใหญ่ของสำนักงานสถิติแห่งชาติ\n\nเคล็ดลับ: ท่านสามารถเลือกหัวข้อแนะนำจากหน้าน้องมาดีเพื่อเริ่มต้นบทสนทนาได้เลย",
                    icon: Icons.chat_bubble_outline
                  ),
                  _buildManualCard(
                    context, 
                    theme,
                    title: "เมนูอื่นๆ",
                    description: "• หมวดหมู่สถิติ: เลือกดูข้อมูลตามสาขาต่างๆ (เปลี่ยนมุมมอง Grid/List ได้ที่มุมขวาบน)\n• ข้อมูลจังหวัด: ดูสถิติรายจังหวัด\n• Infographic: สื่อภาพสรุปข้อมูลสถิติที่น่าสนใจ\n• ปฏิทินข้อมูล: ตรวจสอบกำหนดการเผยแพร่ข้อมูลสถิติล่วงหน้า",
                    icon: Icons.grid_view
                  ),
                   _buildManualCard(
                    context, 
                    theme,
                    title: "ข้อเสนอแนะ (Feedback)",
                    description: "ส่งข้อเสนอแนะหรือแจ้งปัญหาการใช้งานได้ที่เมนู 'ข้อเสนอแนะ' (แถบด้านล่าง) เพื่อให้เรานำไปปรับปรุงแอปพลิเคชัน",
                    icon: Icons.feedback
                  ),
                  _buildManualCard(
                    context, 
                    theme,
                    title: "ติดต่อเรา (Contact Us)",
                    description: "ดูข้อมูลที่ตั้ง เบอร์โทรศัพท์ อีเมล และช่องทางโซเชียลมีเดียของสำนักงานสถิติแห่งชาติ หรือเปิดแผนที่นำทางได้จากเมนู 'ติดต่อเรา'",
                    icon: Icons.contact_support
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCard(BuildContext context, ThemeData theme, {required String title, required String description, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.primaryColor.withOpacity(0.1))
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: theme.primaryColor.withOpacity(0.1),
                 shape: BoxShape.circle
               ),
               child: Icon(icon, color: theme.primaryColor, size: 28),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                   const SizedBox(height: 8),
                   Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.5)),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}
