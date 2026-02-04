import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart'; 
import '../common/profile_page.dart';
import '../../models/member_model.dart'; 
import 'course_browser.dart';
import 'my_courses.dart';
import 'assignment_submission.dart';
import 'top_up_page.dart';
import 'channel_list_page.dart'; // ← 新增：頻道列表頁面

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const SizedBox.shrink(),
    const CourseBrowserPage(),
    const MyCoursesPage(),
    const AssignmentSubmissionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    final Widget bodyContent = _currentIndex == 0 
      ? _buildDashboard(lang, userProvider) 
      : _pages[_currentIndex];

    return Scaffold(
      body: bodyContent, 
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'My Courses'),
          NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Tasks'),
        ],
      ),
    );
  }

  Widget _buildDashboard(LanguageProvider lang, UserProvider user) {
    final tempMember = Member(
      mId: user.mId, fName: user.name, nName: '', mType: 'STUDENT', email: user.email, address: '', tel: 0, points: user.balance
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => await user.refreshBalance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello, ${user.name} 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        Text(lang.t('welcome'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(member: tempMember))),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF6366F1), width: 2)),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopUpPage())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white70),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: const Text("Tap to Top Up", style: TextStyle(color: Colors.white, fontSize: 12)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(user.isLoading ? "..." : user.balance.toStringAsFixed(0), 
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                      ),
                      const Text("Available ACoin", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      Text(user.mId, style: const TextStyle(color: Colors.white54, letterSpacing: 2, fontFamily: 'Monospace')),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              const Text("Explore", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildQuickAction(Icons.search, "Browse", Colors.orange, () => setState(() => _currentIndex = 1)),
                  const SizedBox(width: 16),
                  _buildQuickAction(Icons.play_circle_outline, "Learning", Colors.blue, () => setState(() => _currentIndex = 2)),
                ],
              ),
              
              // ========== 新增：觀看直播入口 ==========
              const SizedBox(height: 24),
              const Text("Live", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChannelListPage()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Watch Live", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Join a live class now", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
              // ========== 結束 ==========
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}