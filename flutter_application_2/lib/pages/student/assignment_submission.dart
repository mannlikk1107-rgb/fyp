// lib/pages/student/assignment_submission.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';

class AssignmentSubmissionPage extends StatefulWidget {
  const AssignmentSubmissionPage({super.key});

  @override
  State<AssignmentSubmissionPage> createState() => _AssignmentSubmissionPageState();
}

class _AssignmentSubmissionPageState extends State<AssignmentSubmissionPage> {
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _currentMId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await LocalStorage.getUserInfo();
    _currentMId = user['mId'];
    
    if (_currentMId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // 1. 取得學生報名的課程
    final cData = await ApiService.getStudentCourses(_currentMId!);
    final myCourses = cData.map((j) => Course.fromJson(j)).toList();

    // 2. 針對每個課程獲取作業 (這裡簡單地用迴圈，正式產品可用 Future.wait 優化)
    List<Assignment> allTasks = [];
    for (var c in myCourses) {
      final tData = await ApiService.getAssignments(c.id, mId: _currentMId);
      final tasks = tData.map((j) {
        // 我們可以在這裡手動把 Course Title 塞進去 Assignment (如果需要顯示)
        // 為了簡單，我們假設作業列表顯示課程 ID 或你自己修改 API 回傳課程名稱
        return Assignment.fromJson(j);
      }).toList();
      allTasks.addAll(tasks);
    }

    // 依照截止日期排序
    allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (mounted) {
      setState(() {
        _assignments = allTasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(title: const Text("My Tasks")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.green[200]),
                  const SizedBox(height: 16),
                  const Text("No pending tasks! Good job.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assignments.length,
              itemBuilder: (ctx, i) {
                final task = _assignments[i];
                return _buildTaskCard(task);
              },
            ),
    );
  }

  Widget _buildTaskCard(Assignment task) {
    final isOverdue = DateTime.now().isAfter(task.dueDate) && !task.isSubmitted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
                if (task.isSubmitted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: const Text("Submitted", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                else if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                    child: const Text("Overdue", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Due: ${task.dueDate.toString().split(' ')[0]}", 
                  style: TextStyle(color: isOverdue ? Colors.red : Colors.grey[700], fontWeight: FontWeight.w500)
                ),
              ],
            ),
            if (task.grade != null) ...[
              const SizedBox(height: 8),
              Text("Grade: ${task.grade}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(task.isSubmitted ? "Re-upload File" : "Upload Solution"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isSubmitted ? Colors.white : const Color(0xFF6366F1),
                  foregroundColor: task.isSubmitted ? const Color(0xFF6366F1) : Colors.white,
                  side: task.isSubmitted ? const BorderSide(color: Color(0xFF6366F1)) : null,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _uploadFile(task),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(Assignment task) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // 允許所有類型，或改為 FileType.custom 並指定副檔名
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      File file = File(result.files.single.path!);
      
      bool success = await ApiService.submitAssignment(task.id, _currentMId!, file);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Submitted successfully!"), backgroundColor: Colors.green)
          );
          _loadData(); // 重新載入以更新 UI 狀態
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload failed. Please try again."), backgroundColor: Colors.red)
          );
        }
      }
    }
  }
}
