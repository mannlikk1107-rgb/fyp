import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/file_service.dart';
import '../../services/local_storage.dart';

class TeacherCourseContentPage extends StatefulWidget {
  final Course course;
  const TeacherCourseContentPage({super.key, required this.course});

  @override
  State<TeacherCourseContentPage> createState() => _TeacherCourseContentPageState();
}

class _TeacherCourseContentPageState extends State<TeacherCourseContentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FileService _fileService = FileService();
  
  List<dynamic> _lessons = [];
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await LocalStorage.getUserInfo();
    
    // 1. 載入 Lessons
    final lData = await ApiService.getCourseContent(widget.course.id, user['mId'] ?? '');
    
    // 2. 載入 Materials (特定課程的檔案)
    final fData = await _fileService.getFiles(courseId: widget.course.id);

    if (mounted) {
      setState(() {
        _lessons = lData['lessons'] ?? [];
        _materials = List<Map<String, dynamic>>.from(fData['files'] ?? []);
        _isLoading = false;
      });
    }
  }

  // --- Actions ---

  // 新增影片 (Lesson)
  void _addLessonDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Lesson"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Lesson Name")),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Video URL (e.g., mp4/YouTube)")),
            TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "Duration (min)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await ApiService.addLesson(
                cId: widget.course.id,
                lName: nameCtrl.text,
                videoUrl: urlCtrl.text,
                duration: durCtrl.text.isEmpty ? '0' : durCtrl.text
              );
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // 上傳教材 (Material)
  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    setState(() => _isLoading = true);
    final user = await LocalStorage.getUserInfo();
    File file = File(result.files.single.path!);

    // 關鍵：這裡傳入了 courseIds: [widget.course.id]
    // 這樣學生端用 getFiles(courseId) 就能看到了
    final res = await _fileService.uploadFile(
      file, 
      result.files.single.name,
      userId: user['mId'] ?? 'unknown',
      courseIds: [widget.course.id], 
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['success'] ? "Uploaded successfully" : "Upload failed"),
        backgroundColor: res['success'] ? Colors.green : Colors.red,
      ));
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Lessons (Videos)"),
            Tab(text: "Materials (Files)"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              // --- Lessons List ---
              Scaffold(
                body: _lessons.isEmpty 
                  ? const Center(child: Text("No lessons yet.")) 
                  : ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (ctx, i) => ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Colors.blue),
                        title: Text(_lessons[i]['lName']),
                        subtitle: Text("${_lessons[i]['duration']} min"),
                      ),
                    ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _addLessonDialog,
                  child: const Icon(Icons.add),
                ),
              ),

              // --- Materials List ---
              Scaffold(
                body: _materials.isEmpty 
                  ? const Center(child: Text("No materials uploaded.")) 
                  : ListView.builder(
                      itemCount: _materials.length,
                      itemBuilder: (ctx, i) {
                        final f = _materials[i];
                        return ListTile(
                          leading: const Icon(Icons.description, color: Colors.orange),
                          title: Text(f['original_name']),
                          subtitle: Text(f['formatted_size'] ?? ''),
                        );
                      },
                    ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _uploadMaterial,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.upload_file),
                ),
              ),
            ],
          ),
    );
  }
}
