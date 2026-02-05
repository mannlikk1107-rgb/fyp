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
    
    try {
      final lData = await ApiService.getCourseContent(widget.course.id, user['mId'] ?? '');
      final fData = await _fileService.getFiles(courseId: widget.course.id);

      if (mounted) {
        setState(() {
          _lessons = lData['lessons'] ?? [];
          if (fData['success'] == true) {
            _materials = List<Map<String, dynamic>>.from(fData['files'] ?? []);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final user = await LocalStorage.getUserInfo();
    File file = File(result.files.single.path!);

    // 上傳檔案
    final res = await _fileService.uploadFile(
      file, 
      result.files.single.name,
      userId: user['mId'] ?? 'unknown',
      courseIds: [widget.course.id], 
    );

    if (mounted) {
      Navigator.pop(context); // 關閉 Loading
      
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload Successful!"), backgroundColor: Colors.green));
        // 強制等待 1 秒讓資料庫寫入
        await Future.delayed(const Duration(seconds: 1));
        _loadData(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${res['error']}"), backgroundColor: Colors.red));
      }
    }
  }

  void _addLessonDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Lesson"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Video URL")),
            TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "Duration (min)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addLesson(
                cId: widget.course.id,
                lName: nameCtrl.text,
                videoUrl: urlCtrl.text,
                duration: durCtrl.text.isEmpty ? '0' : durCtrl.text
              );
              _loadData();
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
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
          tabs: const [Tab(text: "Lessons"), Tab(text: "Materials")],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildLessonList(),
              _buildMaterialList(),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0 ? _addLessonDialog() : _uploadMaterial(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLessonList() {
    if (_lessons.isEmpty) return const Center(child: Text("No lessons yet."));
    return ListView.builder(
      itemCount: _lessons.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.play_circle, color: Colors.blue),
        title: Text(_lessons[i]['lName']),
        subtitle: Text("${_lessons[i]['duration']} min"),
      ),
    );
  }

  Widget _buildMaterialList() {
    if (_materials.isEmpty) return const Center(child: Text("No materials yet."));
    return ListView.builder(
      itemCount: _materials.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.description, color: Colors.orange),
        title: Text(_materials[i]['original_name'] ?? 'File'),
        subtitle: Text(_materials[i]['formatted_size'] ?? ''),
      ),
    );
  }
}
