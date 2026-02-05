import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';
import 'teacher_course_content_page.dart'; // 確保這個檔案存在

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
    setState(() => _isLoading = true);
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

  // --- [關鍵修正] 新增刪除邏輯 ---
  Future<void> _deleteCourse(Course course) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete '${course.title}'? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true); // 顯示 Loading
      bool success = await ApiService.deleteCourse(course.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? "Course deleted successfully" : "Failed to delete course"),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        // 重新載入列表以刷新 UI
        await _loadTeacherCourses(); 
      }
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
                    padding: const EdgeInsets.all(16),
                    itemCount: _myCourses.length,
                    itemBuilder: (context, index) {
                      final course = _myCourses[index];
                      // --- [關鍵修正] 將 Card 改為 InkWell + Card ---
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias, // 讓 InkWell 的波紋效果在圓角內
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => TeacherCourseContentPage(course: course))
                            ).then((_) => _loadTeacherCourses()); // 從內容頁回來後刷新
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 0, 16), // 調整 padding 給 PopupMenuButton 留空間
                            child: _buildCourseCardContent(course),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // --- [重構] 將 Card 內容提取出來 ---
  Widget _buildCourseCardContent(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
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
                  Text("Price: HK\$ ${course.price.toStringAsFixed(0)}", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            // --- [關鍵修正] PopupMenuButton 放在 Row 裡面 ---
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCourse(course);
                } else if (value == 'edit') {
                  // TODO: 實作編輯課程資訊的功能
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit Info')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete Course')])),
              ],
            ),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Students", course.studentCount.toString(), Icons.people, Colors.green),
            _buildStatColumn("Lessons", course.totalLesson.toString(), Icons.list_alt, Colors.orange),
            _buildStatColumn("Revenue", "HK\$${(course.price * course.studentCount).toStringAsFixed(0)}", Icons.monetization_on, Colors.blue),
          ],
        ),
      ],
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
            "Tap the '+' button in the bottom navigation to create one.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
