import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class LiveHistoryPage extends StatelessWidget {
  const LiveHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final liveSessions = [
      {
        'course': Course(id: '1', title: 'UI/UX Design Fundamentals', teacherName: 'John Doe', price: 99, category: 'Design', teacherId: 'T1'),
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'duration': '1:30:25',
        'viewers': 45,
      },
      {
        'course': Course(id: '2', title: 'Advanced Prototyping', teacherName: 'John Doe', price: 149, category: 'Design', teacherId: 'T1'),
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'duration': '2:15:10',
        'viewers': 67,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Live History'),
        backgroundColor: Colors.transparent, // Consistent with new theme
      ),
      body: liveSessions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: liveSessions.length,
              itemBuilder: (context, index) {
                return _buildHistoryCard(liveSessions[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No live sessions have been recorded",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> session) {
    final course = session['course'] as Course;
    final date = session['date'] as DateTime;
    final duration = session['duration'] as String;
    final viewers = session['viewers'] as int;

    // Mock calculation for revenue for demo purposes
    final mockRevenue = (viewers * 0.5) + (course.price * 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Course Title and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          // Stats Row: Duration, Viewers, Revenue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("Duration", duration, Icons.timer_outlined, Colors.orange),
              _buildStat("Viewers", viewers.toString(), Icons.people_outline, Colors.blue),
              _buildStat("Revenue", "\$${mockRevenue.toStringAsFixed(2)}", Icons.monetization_on_outlined, Colors.green),
            ],
          )
        ],
      ),
    );
  }

  // Helper widget for displaying a single statistic
  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
