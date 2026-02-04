import 'package:flutter/material.dart';
import '../../models/course_model.dart'; // Assuming your Assignment model is here

class AssignmentManagementPage extends StatefulWidget {
  const AssignmentManagementPage({super.key});

  @override
  State<AssignmentManagementPage> createState() => _AssignmentManagementPageState();
}

class _AssignmentManagementPageState extends State<AssignmentManagementPage> {
  // Mock Data
  final List<Assignment> _assignments = [
    Assignment(
      id: '1', courseId: '1', title: 'Design Portfolio Project',
      description: 'Create a comprehensive design portfolio',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Assignment(
      id: '2', courseId: '1', title: 'User Research Report',
      description: 'Conduct user research for a mobile app',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Manage Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _createAssignment,
          ),
        ],
      ),
      body: _assignments.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                return _buildAssignmentCard(_assignments[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No assignments created yet", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.assignment, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Due: ${_formatDate(assignment.dueDate)}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[500]),
            onSelected: (value) {
              if (value == 'edit') _editAssignment(assignment, index);
              if (value == 'grade') _gradeAssignment(assignment);
              if (value == 'delete') _deleteAssignment(assignment);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'grade', child: Row(children: [Icon(Icons.score, size: 20), SizedBox(width: 8), Text('Grade')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  
  void _createAssignment() => _showAssignmentDialog(null, null);
  void _editAssignment(Assignment assignment, int index) => _showAssignmentDialog(assignment, index);

  void _showAssignmentDialog(Assignment? assignment, int? index) {
    final titleCtrl = TextEditingController(text: assignment?.title ?? '');
    final descCtrl = TextEditingController(text: assignment?.description ?? '');
    DateTime selectedDate = assignment?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(assignment == null ? 'Create Assignment' : 'Edit Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Due Date"),
                      subtitle: Text(_formatDate(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isEmpty) return;
                    
                    final newAssignment = Assignment(
                      id: assignment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      courseId: '1',
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      dueDate: selectedDate,
                      createdAt: assignment?.createdAt ?? DateTime.now(),
                    );

                    setState(() {
                      if (index != null) {
                        _assignments[index] = newAssignment; 
                      } else {
                        _assignments.add(newAssignment); 
                      }
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(assignment == null ? 'Assignment Created' : 'Assignment Updated')));
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _gradeAssignment(Assignment assignment) {
    final students = [
      {'name': 'Alice', 'status': 'Submitted', 'score': '85'},
      {'name': 'Bob', 'status': 'Pending', 'score': ''},
      {'name': 'Charlie', 'status': 'Submitted', 'score': '92'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Grade: ${assignment.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (context, i) {
              final s = students[i];
              return ListTile(
                leading: CircleAvatar(child: Text(s['name']![0])),
                title: Text(s['name']!),
                subtitle: Text(s['status']!, style: TextStyle(color: s['status'] == 'Submitted' ? Colors.green : Colors.red)),
                trailing: SizedBox(
                  // [FIX] Increased width to allow for 2-3 digit scores
                  width: 80, 
                  child: TextFormField(
                    initialValue: s['score'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Score',
                      // isDense: true, // Removed this to give more space
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grades Saved!')));
            },
            child: const Text('Save Grades'),
          ),
        ],
      ),
    );
  }
  
  void _deleteAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _assignments.removeWhere((a) => a.id == assignment.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment deleted'), backgroundColor: Colors.red),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
