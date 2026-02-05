import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../widgets/course_card.dart'; // 引入新組件
import '../common/course_detail_page.dart';

class CourseBrowserPage extends StatefulWidget {
  const CourseBrowserPage({super.key});

  @override
  State<CourseBrowserPage> createState() => _CourseBrowserPageState();
}

class _CourseBrowserPageState extends State<CourseBrowserPage> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = ApiService.getAllCourses().then((data) {
        return data.map((json) => Course.fromJson(json)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 safe area 但不加 AppBar，讓設計更像現代 App
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 自定義頭部
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Explore", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Find the perfect course for you", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  // 搜尋框裝飾
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search for courses...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 列表內容
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FutureBuilder<List<Course>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return const Center(child: Text("No courses available."));
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadCourses(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80), // 避免被底部導航遮擋
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          // 使用共用組件
                          return CourseCard(
                            course: course,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailPage(course: course))),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
