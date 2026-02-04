import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 课程封面
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
              ),
              child: const Icon(Icons.school, size: 80, color: Colors.blue),
            ),

            // 课程信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${course.teacherName}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange[400]),
                      const SizedBox(width: 4),
                      Text(course.rating.toString()),
                      const SizedBox(width: 16),
                      Icon(Icons.people, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${course.studentCount} students'),
                      const SizedBox(width: 16),
                      Icon(Icons.category, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(course.category),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    course.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  // 课程特色
                  const Text(
                    'What you\'ll learn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildLearningOutcomes(),
                  const SizedBox(height: 24),

                  // 价格和操作按钮
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '\$${course.price}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // 加入课程
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully enrolled in course!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Enroll Now'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLearningOutcomes() {
    final outcomes = [
      'Master fundamental design principles',
      'Create professional UI/UX designs',
      'Build interactive prototypes',
      'Understand user research methods',
      'Develop design systems',
    ];

    return outcomes.map((outcome) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(outcome)),
        ],
      ),
    )).toList();
  }
}