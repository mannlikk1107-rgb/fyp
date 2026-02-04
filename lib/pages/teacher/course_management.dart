import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  List<Course> _myCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherCourses();
  }

  Future<void> _loadTeacherCourses() async {
    final user = await LocalStorage.getUserInfo();
    final mId = user['mId'];
    
    if (mId != null && mId.isNotEmpty) {
      final data = await ApiService.getTeacherCourses(mId);
      if (mounted) {
        setState(() {
          _myCourses = data.map((json) => Course.fromJson(json)).toList();
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
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCourses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTeacherCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _myCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_myCourses[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "You haven't created any courses yet.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the '+' button to create your first course.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    image: course.coverImage != null 
                        ? DecorationImage(image: NetworkImage(course.coverImage!), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: course.coverImage == null ? const Icon(Icons.school, color: Colors.blue) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Price: \$${course.price.toStringAsFixed(0)}", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Info')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Course')),
                  ],
                  onSelected: (value) { /* Handle actions */ },
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("Students", course.studentCount.toString(), Icons.people, Colors.green),
                _buildStatColumn("Lessons", course.totalLesson.toString(), Icons.list_alt, Colors.orange),
                _buildStatColumn("Revenue", "\$${(course.price * course.studentCount).toStringAsFixed(0)}", Icons.monetization_on, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
