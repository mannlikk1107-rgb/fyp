import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({super.key});

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  final List<Map<String, dynamic>> _watchHistory = [
    {
      'course': Course(
        id: '1',
        title: 'UI/UX Design Fundamentals',
        description: 'Learn the basics of user interface and experience design',
        teacherId: 'T001',
        teacherName: 'John Doe',
        category: 'Design',
        price: 99.99,
        rating: 4.8,
        studentCount: 150,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isLive: false,
        schedules: [],
      ),
      'lastWatched': DateTime.now().subtract(const Duration(hours: 2)),
      'progress': 0.85,
      'duration': '45:30',
      'position': '38:45',
    },
    {
      'course': Course(
        id: '2',
        title: 'Advanced Prototyping',
        description: 'Master prototyping techniques with modern tools',
        teacherId: 'T002',
        teacherName: 'Jane Smith',
        category: 'Design',
        price: 149.99,
        rating: 4.9,
        studentCount: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isLive: true,
        schedules: [],
      ),
      'lastWatched': DateTime.now().subtract(const Duration(days: 1)),
      'progress': 0.45,
      'duration': '1:15:20',
      'position': '34:10',
    },
    {
      'course': Course(
        id: '3',
        title: 'Design Systems',
        description: 'Create scalable design systems for large projects',
        teacherId: 'T003',
        teacherName: 'Mike Johnson',
        category: 'Design',
        price: 199.99,
        rating: 4.7,
        studentCount: 120,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isLive: false,
        schedules: [],
      ),
      'lastWatched': DateTime.now().subtract(const Duration(days: 3)),
      'progress': 0.25,
      'duration': '52:15',
      'position': '13:05',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _watchHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _watchHistory.length,
              itemBuilder: (context, index) {
                final history = _watchHistory[index];
                final course = history['course'] as Course;
                final lastWatched = history['lastWatched'] as DateTime;
                final progress = history['progress'] as double;
                final duration = history['duration'] as String;
                final position = history['position'] as String;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.play_circle_fill, color: Colors.blue),
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(course.teacherName),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Last watched: ${_formatDate(lastWatched)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              position,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(' / ', style: TextStyle(fontSize: 12)),
                            Text(
                              duration,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // 继续观看
                        _continueWatching(course, position);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Watch History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your watched videos will appear here. Start learning to build your history!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Browse Courses'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _continueWatching(Course course, String position) {
    // 模拟继续观看功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue Watching'),
        content: Text('Continue "${course.title}" from $position?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 实际应用中这里会跳转到视频播放器
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Continuing from saved position...'),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all watch history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _watchHistory.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Watch history cleared'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}