import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';
import '../../widgets/course_card.dart'; // 引入新組件
import '../common/course_detail_page.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  List<Course> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyCourses();
  }

  Future<void> _loadMyCourses() async {
    final user = await LocalStorage.getUserInfo();
    final mId = user['mId'];
    if (mId != null && mId.isNotEmpty) {
      final data = await ApiService.getStudentCourses(mId);
      if (mounted) {
        setState(() {
          _enrolledCourses = data.map((json) => Course.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _enrolledCourses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("No enrolled courses yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _enrolledCourses.length,
                  itemBuilder: (context, index) {
                    final course = _enrolledCourses[index];
                    return CourseCard(
                      course: course,
                      statusText: "In Progress", // 顯示狀態
                      statusColor: Colors.orange,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)));
                      },
                    );
                  },
                ),
    );
  }
}
