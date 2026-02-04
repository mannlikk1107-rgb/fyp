import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/course_model.dart';

class AssignmentSubmissionPage extends StatefulWidget {
  const AssignmentSubmissionPage({super.key});

  @override
  State<AssignmentSubmissionPage> createState() => _AssignmentSubmissionPageState();
}

class _AssignmentSubmissionPageState extends State<AssignmentSubmissionPage> {
  // 模擬數據
  final List<Assignment> _assignments = [
    Assignment(
      id: '1',
      courseId: '1',
      title: 'Design Portfolio Project',
      description: 'Create a comprehensive design portfolio showcasing your skills in UI/UX design.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      attachmentUrl: 'https://example.com/assignment1.pdf',
    ),
    Assignment(
      id: '2',
      courseId: '1',
      title: 'User Research Report',
      description: 'Conduct user research for a mobile app and submit a detailed report.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Assignment(
      id: '3',
      courseId: '2',
      title: 'Prototype Implementation',
      description: 'Create an interactive prototype using Figma.',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

  // 為了顯示課程名稱，這裡模擬一個簡單的查找 Map
  final Map<String, String> _courseNames = {
    '1': 'UI/UX Design Fundamentals',
    '2': 'Advanced Prototyping',
  };

  int _selectedTab = 0; // 0: Pending, 1: Submitted, 2: Graded

  @override
  Widget build(BuildContext context) {
    // 簡單的過濾邏輯
    final pendingAssignments = _assignments.where((a) => a.dueDate.isAfter(DateTime.now())).toList();
    final submittedAssignments = _assignments.where((a) => a.dueDate.isBefore(DateTime.now()) && a.dueDate.isAfter(DateTime.now().subtract(const Duration(days: 5)))).toList();
    final gradedAssignments = _assignments.where((a) => a.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 5)))).toList();

    List<Assignment> currentList;
    
    // FIX 1: 添加大括號，解決 curly_braces_in_flow_control_structures 錯誤
    if (_selectedTab == 0) {
      currentList = pendingAssignments;
    } else if (_selectedTab == 1) {
      currentList = submittedAssignments;
    } else {
      currentList = gradedAssignments;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // 與首頁一致的背景色
      body: SafeArea(
        child: Column(
          children: [
            // 1. 頂部標題
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Text(
                    "Assignments",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  )
                ],
              ),
            ),
            // 2. 現代化分頁切換 (Custom Tab Bar)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  _buildTabItem(0, "Pending"),
                  _buildTabItem(1, "Submitted"),
                  _buildTabItem(2, "Graded"),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // 3. 作業列表
            Expanded(
              child: currentList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        return _buildAssignmentCard(currentList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 自定義分頁按鈕
  Widget _buildTabItem(int index, String text) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // 自定義作業卡片
  Widget _buildAssignmentCard(Assignment assignment) {
    String statusText = _selectedTab == 0 ? "Due in ${_daysLeft(assignment.dueDate)} days" : (_selectedTab == 1 ? "Under Review" : "Score: A");
    Color statusColor = _selectedTab == 0 ? Colors.orange : (_selectedTab == 1 ? Colors.blue : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片頂部：狀態標籤 + 課程名稱
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Text(
                _formatDate(assignment.dueDate),
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 標題與描述
          Text(
            assignment.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Text(
            _courseNames[assignment.courseId] ?? "Unknown Course",
            style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            assignment.description,
            style: TextStyle(color: Colors.grey[600], height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // 底部按鈕
          SizedBox(
            width: double.infinity,
            child: _selectedTab == 0
                ? ElevatedButton(
                    onPressed: () => _submitAssignment(assignment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Submit Work", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : OutlinedButton(
                    onPressed: () => _viewAssignment(assignment),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text("View Details", style: TextStyle(color: Colors.grey[700])),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No assignments found",
            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  int _daysLeft(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  Future<void> _submitAssignment(Assignment assignment) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );

    if (result != null) {
      // 確保 widget 仍然掛載才顯示 dialog
      if (!mounted) return;

      // 模擬上傳延遲
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      await Future.delayed(const Duration(seconds: 1));
      
      // FIX 2: 再次檢查 mounted，解決 use_build_context_synchronously 錯誤
      // 因為在 await 期間 widget 可能已被銷毀
      if (!mounted) return;

      Navigator.pop(context); // 關閉 loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully!'), backgroundColor: Colors.green),
      );
      // 這裡為了演示，可以手動將該作業移到 Submitted 列表 (邏輯省略)
    }
  }

  void _viewAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(assignment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Teacher Feedback:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Text("Great job! I liked your attention to detail.", style: TextStyle(color: Colors.green)),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}
