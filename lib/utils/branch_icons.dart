import 'package:flutter/material.dart';

class BranchIcons {
  static IconData getIcon(String branchId) {
    if (branchId.isEmpty) return Icons.table_chart;
    
    switch (branchId) {
      case '101': return Icons.groups; // ประชากร
      case '102': return Icons.engineering; // แรงงาน
      case '103': return Icons.school; // การศึกษา
      case '104': return Icons.temple_buddhist; // ศาสนา
      case '105': return Icons.health_and_safety; // สุขภาพ
      case '106': return Icons.volunteer_activism; // สวัสดิการสังคม
      case '107': return Icons.person_pin; // หญิงและชาย (Gender)
      case '108': return Icons.account_balance_wallet; // รายได้รายจ่าย
      case '109': return Icons.gavel; // ยุติธรรม
      case '210': return Icons.account_balance; // บัญชีประชาชาติ
      case '211': return Icons.agriculture; // เกษตรและประมง
      case '212': return Icons.factory; // อุตสาหกรรม
      case '213': return Icons.bolt; // พลังงาน
      case '214': return Icons.storefront; // การค้าและราคา
      case '215': return Icons.local_shipping; // ขนส่งและโลจิสติกส์
      case '216': return Icons.router; // ICT
      case '217': return Icons.flight_takeoff; // การท่องเที่ยว
      case '218': return Icons.monetization_on; // การเงิน
      case '219': return Icons.request_quote; // การคลัง
      case '220': return Icons.science; // วิทยาศาสตร์
      case '321': return Icons.forest; // สิ่งแวดล้อม
      default: return Icons.table_chart;
    }
  }
}
