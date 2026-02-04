// 路徑: lib/pages/teacher/teacher_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/language_provider.dart';
import '../../models/member_model.dart';
import '../../services/local_storage.dart';
import '../../services/api_service.dart';

// --- 正確的 import ---
import '../common/profile_page.dart';
import 'create_course_page.dart';
import 'course_management.dart'; // 這是管理課程的頁面
import 'assignment_management.dart'; // 這是管理作業的頁面
import 'live_history.dart';
import '../common/file_management.dart'; // 這是檔案管理頁面

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;
  TeacherProfile? _profile;
  double _totalEarnings = 0.0;

  static const String _mediaPipeUrl = 'https://d2kry3pmi7k9be.cloudfront.net/MediaPipe.html';

  final List<Widget> _pages = [
    const SizedBox(), // Dashboard
    const CourseManagementPage(),     // 這裡現在應該沒問題了
    const AssignmentManagementPage(), // 這裡也沒問題了
    const FileManagementPage(),       // 這裡也沒問題了
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final info = await LocalStorage.getUserInfo();
    final mId = info['mId'] ?? '';
    
    double earnings = 0.0;
    if (mId.isNotEmpty) {
      final coursesData = await ApiService.getTeacherCourses(mId);
      for (var c in coursesData) {
        double price = double.tryParse(c['unitPrice'].toString()) ?? 0;
        int students = int.tryParse(c['studentCount'].toString()) ?? 0;
        earnings += (price * students);
      }
    }
    
    if (mounted) {
      setState(() {
        _totalEarnings = earnings;
        _profile = TeacherProfile(
          mId: mId,
          fName: info['fName'] ?? 'Teacher',
          nName: info['nName'] ?? '',
          email: info['email'] ?? '',
          mType: 'TEACHER',
          address: info['address'] ?? 'N/A',
          tel: int.tryParse(info['tel'] ?? '0') ?? 0,
        );
      });
    }
  }

  Future<void> _launchMediaPipe() async {
    final uri = Uri.parse(_mediaPipeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open the live page')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    Widget content = _profile == null 
        ? const Center(child: CircularProgressIndicator()) 
        : (_currentIndex == 0 ? _buildDashboard(lang) : _pages[_currentIndex]);
    
    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder), label: 'Files'),
        ],
      ),
      floatingActionButton: _currentIndex == 1 ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCoursePage())),
        icon: const Icon(Icons.add),
        label: Text(lang.t('create_course')),
      ) : null,
    );
  }

  Widget _buildDashboard(LanguageProvider lang) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.t('welcome'), style: TextStyle(color: Colors.grey[600])),
                    Text(_profile?.fName ?? 'Teacher', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(member: _profile!))),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(_profile?.fName[0] ?? 'T', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Earnings", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text("HK\$ ${_totalEarnings.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _actionCard(Icons.video_call, "Start Live", Colors.orange, _launchMediaPipe),
                _actionCard(Icons.history, "History", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveHistoryPage()))),
                _actionCard(Icons.analytics_outlined, "Analytics", Colors.purple, () {}),
                _actionCard(Icons.settings_outlined, "Settings", Colors.grey, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
