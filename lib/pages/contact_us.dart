import 'package:flutter/material.dart';
import 'package:nsothinktank/pages/contact_us_web.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  
  Future<void> _launchMap() async {
    // Coordinates for National Statistical Office, Thailand (Government Complex)
    final Uri googleMapsUrl = Uri.parse("https://maps.app.goo.gl/kXj8daHwWE13yWAA6");
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ไม่สามารถเปิดแผนที่ได้")));
    }
  }

  Future<void> _launchPhone(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(launchUri)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ไม่สามารถโทรออกได้")));
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(launchUri)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ไม่สามารถส่งอีเมลได้")));
    }
  }

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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
        child: SingleChildScrollView(
          child: Column(
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.contact_support, color: theme.primaryColor, size: 28),
                     const SizedBox(width: 8),
                    Text(
                      "ติดต่อเรา",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Google Maps Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _launchMap,
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Placeholder for Map, using an Icon pattern if no image
                                  Opacity(
                                    opacity: 0.1,
                                    child: Image.asset('assets/images/nso.png', fit: BoxFit.cover), // Fallback background
                                  ),
                                  Center(
                                    child: Icon(Icons.map_outlined, size: 60, color: theme.primaryColor),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.directions, size: 16, color: theme.primaryColor),
                                          const SizedBox(width: 4),
                                          Text("นำทาง", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, color: theme.primaryColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("ที่อยู่ไปรษณีย์", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ศูนย์ราชการเฉลิมพระเกียรติ 80 พรรษา อาคาร C ชั้น 5-11 ซอยแจ้งวัฒนะ 7 ถนนแจ้งวัฒนะ เขตหลักสี่ กทม. 10210",
                                          style: TextStyle(color: Colors.grey[600], height: 1.5),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Channels
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildContactTile(
                            icon: Icons.phone,
                            title: "งานประชาสัมพันธ์",
                            subtitle: "0 2142 1234",
                            onTap: () => _launchPhone('021421234'),
                            theme: theme,
                          ),
                          const Divider(height: 1, indent: 56),
                           _buildContactTile(
                            icon: Icons.phone_in_talk,
                            title: "บริการข้อมูลสถิติ",
                            subtitle: "0 2141 7500",
                            onTap: () => _launchPhone('021417500'),
                            theme: theme,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildContactTile(
                            icon: Icons.email,
                            title: "อีเมล (ประชาสัมพันธ์)",
                            subtitle: "prgroup@nso.go.th",
                            onTap: () => _launchEmail('prgroup@nso.go.th'),
                            theme: theme,
                          ),
                           const Divider(height: 1, indent: 56),
                          _buildContactTile(
                            icon: Icons.email_outlined,
                            title: "อีเมล (บริการข้อมูล)",
                            subtitle: "services@nso.go.th",
                            onTap: () => _launchEmail('services@nso.go.th'),
                            theme: theme,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildContactTile(
                            icon: Icons.language,
                            title: "เว็บไซต์",
                            subtitle: "www.nso.go.th",
                            onTap: () {
                               Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ContactUsWebPage()));
                            },
                            theme: theme,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom sheet
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      trailing: trailing,
    );
  }
}

