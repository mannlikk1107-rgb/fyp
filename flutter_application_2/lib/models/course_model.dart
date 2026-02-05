// 路徑: lib/models/course_model.dart

class Course {
  final String id;          // DB: cId
  final String title;       // DB: cName
  final double price;       // DB: unitPrice
  final String category;    // DB: cateId
  final String teacherId;   // DB: mId
  final int totalLesson;    // DB: totalLesson
  final String languageId;  // DB: langId
  
  // UI & 擴充欄位
  final String description;
  final String teacherName;
  final String? coverImage;
  final double rating;
  final int studentCount;
  final DateTime? createdAt; // 修復 watch_history 錯誤
  final bool isLive;         // 修復 watch_history 錯誤
  final List<dynamic> schedules; // 修復 watch_history 錯誤

  Course({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.teacherId,
    this.totalLesson = 0,
    this.languageId = 'en',
    this.description = 'No description available',
    this.teacherName = 'Instructor',
    this.coverImage,
    this.rating = 0.0,
    this.studentCount = 0,
    this.createdAt,
    this.isLive = false,
    this.schedules = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['cId']?.toString() ?? '',
      title: json['cName']?.toString() ?? 'Untitled',
      price: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      category: json['cateId']?.toString() ?? 'General',
      teacherId: json['mId']?.toString() ?? '',
      totalLesson: int.tryParse(json['totalLesson']?.toString() ?? '0') ?? 0,
      languageId: json['langId']?.toString() ?? 'en',
      
      // UI 欄位填充
      teacherName: json['teacherName'] ?? 'Unknown',
      description: json['description'] ?? 'Imported from DB',
      studentCount: int.tryParse(json['studentCount']?.toString() ?? '0') ?? 0,
      coverImage: json['coverImage'],
      createdAt: DateTime.tryParse(json['createDate'] ?? ''),
      isLive: json['isLive'] == true || json['isLive'] == 1,
    );
  }
}

// 作業相關模型 (保持不變)
class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isSubmitted;
  final String? grade;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isSubmitted = false,
    this.grade,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['aId']?.toString() ?? '',
      courseId: json['cId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      isSubmitted: json['isSubmitted'] == true,
      grade: json['grade'],
    );
  }
}

class AssignmentSubmission {
  final String subId;
  final String studentName;
  final String fileUrl;
  final String fileName;
  final DateTime submitDate;
  final String? grade;

  AssignmentSubmission({
    required this.subId,
    required this.studentName,
    required this.fileUrl,
    required this.fileName,
    required this.submitDate,
    this.grade,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      subId: json['subId']?.toString() ?? '',
      studentName: "${json['fName'] ?? ''} ${json['nName'] ?? ''}".trim(),
      fileUrl: json['filePath'] ?? '',
      fileName: json['fileName'] ?? 'File',
      submitDate: DateTime.tryParse(json['submitDate'] ?? '') ?? DateTime.now(),
      grade: json['grade'],
    );
  }
}
