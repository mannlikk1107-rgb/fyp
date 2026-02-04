import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';
import '../student/top_up_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _isEnrolling = false;
  bool _isEnrolled = false;
  bool _isLoadingContent = true;
  List<dynamic> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadCourseContent();
  }

  Future<void> _loadCourseContent() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.mId.isEmpty) {
      if(mounted) setState(() => _isLoadingContent = false);
      return;
    }
    final data = await ApiService.getCourseContent(widget.course.id, userProvider.mId);
    if (mounted) {
      setState(() {
        _isEnrolled = data['isEnrolled'] == true;
        _lessons = data['lessons'] ?? [];
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _handleEnroll() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.mId.isEmpty) return;
    setState(() => _isEnrolling = true);

    if (userProvider.balance < widget.course.price) {
      if(!mounted) return;
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white, // 強制白底
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Insufficient Funds", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          content: Text(
            "You need ${widget.course.price} ACoin but you only have ${userProvider.balance.toStringAsFixed(0)}.",
            style: const TextStyle(color: Colors.black87), // [關鍵] 強制黑字
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TopUpPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
              child: const Text("Top Up"),
            )
          ],
        ),
      );
      
      setState(() => _isEnrolling = false);
      return;
    }

    final result = await ApiService.enrollCourse(memberId: userProvider.mId, courseId: widget.course.id, price: widget.course.price);
    
    if (mounted) {
      if (result['success'] == true) {
        await userProvider.refreshBalance();
        setState(() => _isEnrolled = true);
        _loadCourseContent();
        _showDialog("Success", "You are now enrolled!", isError: false);
      } else {
        _showDialog("Failed", result['message'], isError: true);
      }
      setState(() => _isEnrolling = false);
    }
  }

  void _showDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: isError ? Colors.red : Colors.green),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.black87))
        ]),
        content: Text(content, style: const TextStyle(color: Colors.black87)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  Future<void> _openLesson(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) return;
    final Uri url = Uri.parse(videoUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw 'err';
    } catch (e) {
      if(mounted) _showDialog("Content", videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.course.coverImage != null 
                ? Image.network(widget.course.coverImage!, fit: BoxFit.cover)
                : Container(color: Colors.indigo.shade50, child: const Icon(Icons.school_rounded, size: 80, color: Colors.indigo)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(widget.course.category), backgroundColor: Colors.indigo.withValues(alpha: 0.1), labelStyle: const TextStyle(color: Colors.indigo)),
                      Text("${widget.course.price} ACoin", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.course.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.person, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(widget.course.teacherName, style: const TextStyle(color: Colors.grey))]),
                  const SizedBox(height: 24),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(widget.course.description, style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 15)),
                  const SizedBox(height: 32),
                  const Text("Course Content", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
          _isLoadingContent 
            ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lesson = _lessons[index];
                    bool isLocked = !_isEnrolled;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey[50] : Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: isLocked ? Colors.grey[300] : Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(isLocked ? Icons.lock : Icons.play_arrow, color: isLocked ? Colors.grey : Colors.indigo),
                        ),
                        title: Text(lesson['lName'] ?? "Lesson ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.black87)),
                        subtitle: Text("${lesson['duration']} min", style: const TextStyle(color: Colors.grey)),
                        onTap: isLocked ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enroll to unlock"))) : () => _openLesson(lesson['video']),
                      ),
                    );
                  },
                  childCount: _lessons.length,
                ),
              ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: !_isEnrolled 
        ? Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isEnrolling ? null : _handleEnroll,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isEnrolling 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Enroll Now • ${widget.course.price} ACoin", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        : null,
    );
  }
}
