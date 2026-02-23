import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:nsothinktank/utils/analytics_manager.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController(); // Optional contact
  String _selectedType = 'ข้อเสนอแนะทั่วไป';
  bool _isSubmitting = false;

  final List<String> _feedbackTypes = [
    'ข้อเสนอแนะทั่วไป',
    'ปัญหาการใช้งาน',
    'สอบถามข้อมูลสถิติ',
    'แจ้งบั๊ก/ข้อผิดพลาด',
    'อื่นๆ'
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsManager.logEvent('view_feedback_page');
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await AnalyticsManager.getUserId();
      final appVersion = await AnalyticsManager.getAppVersion();
      final url = Uri.parse('https://thaistat.nso.go.th/api/insert_feedback.php');
      
      final response = await http.post(
        url, 
        body: {
          'user_id': userId,
          'sender_name': 'User', // ตรงกับคอลัมน์ sender_name
          'feedback_type': _selectedType, // เพิ่มประเภทข้อเสนอแนะ
          'message': _feedbackController.text, // ตรงกับคอลัมน์ message
          'contact_info': _contactController.text, // ตรงกับคอลัมน์ contact_info
          'app_version': appVersion,
        },
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ส่งข้อเสนอแนะเรียบร้อยแล้ว ขอบคุณครับ')),
            );
            _feedbackController.clear();
            _contactController.clear();
            AnalyticsManager.logEvent('submit_feedback', parameters: {'status': 'success'});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message'] ?? 'ลองใหม่อีกครั้ง'}')),
            );
            AnalyticsManager.logEvent('submit_feedback', parameters: {'status': 'api_error', 'msg': data['message']});
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.statusCode}')),
          );
          AnalyticsManager.logEvent('submit_feedback', parameters: {'status': 'error_${response.statusCode}'});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้')),
        );
        AnalyticsManager.logEvent('submit_feedback', parameters: {'status': 'connection_error'});
      }
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Column(
             children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.feedback, color: theme.primaryColor),
                     const SizedBox(width: 8),
                    Text(
                      "ข้อเสนอแนะ",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                         children: [
                           Icon(Icons.feedback_outlined, size: 50, color: theme.primaryColor.withOpacity(0.8)),
                           const SizedBox(height: 8),
                           Text(
                             "ความคิดเห็นของคุณสําคัญสําหรับเรา",
                             style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                             textAlign: TextAlign.center,
                           ),
                      const SizedBox(height: 4),
                      Text(
                        "ช่วยเราปรับปรุงแอปพลิเคชันให้ดียิ่งขึ้น\nโดยการส่งข้อเสนอแนะหรือปัญหาการใช้งาน",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text("ประเภทข้อเสนอแนะ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: _feedbackTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text("รายละเอียดข้อเสนอแนะ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "พิมพ์รายละเอียดของคุณที่นี่...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกข้อความ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text("ข้อมูลติดต่อ (ไม่บังคับ)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    hintText: "เบอร์โทรศัพท์ หรือ อีเมล",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("ส่งข้อเสนอแนะ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
             ],
          ),
        ),
      ),
      );
    },
  ),
    );
  }
}
