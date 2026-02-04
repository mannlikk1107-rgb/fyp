class Course {
  // --- 資料庫對應欄位 ---
  final String id;          // DB: cId
  final String title;       // DB: cName
  final double price;       // DB: unitPrice
  final String category;    // DB: cateId
  final String teacherId;   // DB: mId
  final int totalLesson;    // DB: totalLesson
  final String languageId;  // DB: langId

  // --- UI 專用欄位 (DB若無則給預設值) ---
  final String description;
  final String teacherName;
  final String? coverImage; // ✅ 支援圖片網址
  final double rating;
  final int studentCount;
  final DateTime? createdAt;
  final bool isLive;
  final bool isFeatured;
  final List<dynamic> schedules;

  Course({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.teacherId,
    this.totalLesson = 0,
    this.languageId = 'en',
    // UI 欄位給予預設值，防止報錯
    this.description = 'No description available',
    this.teacherName = 'Instructor',
    this.coverImage,
    this.rating = 0.0,
    this.studentCount = 0,
    this.createdAt,
    this.isLive = false,
    this.isFeatured = false,
    this.schedules = const [],
  });

  // 從資料庫 JSON 轉換
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
      
      // ✅ 關鍵修正：解析 coverImage
      coverImage: json['coverImage'], 
    );
  }
}

class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String? attachmentUrl;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    this.attachmentUrl,
  });
}

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final String? fileUrl;
  final String? grade;
  final String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    this.fileUrl,
    this.grade,
    this.feedback,
  });
}

class Schedule {
  final DateTime date;
  final String startTime;
  final String endTime;
  
  Schedule({required this.date, required this.startTime, required this.endTime});
}
