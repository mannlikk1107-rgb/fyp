// 路徑: lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/database.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  // 1. 登入 (Login.php)
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String userType = 'auto',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(DatabaseConfig.getLoginUrl()),
        body: {'username': username, 'password': password, 'userType': userType},
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // 2. 管理員登入 (複用 login)
  static Future<Map<String, dynamic>> adminLogin({
    required String username, 
    required String password
  }) async {
    return login(username: username, password: password, userType: 'ADMIN');
  }

  // 3. 註冊 (Register.php)
  static Future<bool> register({
    required String fName,
    required String nName,
    required String email,
    required String password,
    required String address,
    required String tel,
    required String mType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(DatabaseConfig.getRegisterUrl()),
        body: {
          'fName': fName, 'nName': nName, 'email': email, 'password': password,
          'address': address, 'tel': tel, 'mType': mType, 'loginMethod': 'SYSTEM'
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
         try {
            final data = jsonDecode(response.body);
            return data['success'] == true;
         } catch (e) {
            return true; // 容錯
         }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 4. 獲取錢包餘額 (get_wallet_balance.php)
  static Future<double> getWalletBalance(String memberId) async {
    try {
      final response = await http.post(
        Uri.parse(DatabaseConfig.getWalletUrl()),
        body: {'mId': memberId},
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return double.tryParse(data['balance'].toString()) ?? 0.0;
        }
      }
    } catch (e) {
      debugPrint("Balance error: $e");
    }
    return 0.0;
  }

  // 5. 獲取所有課程 (get_courses.php)
  static Future<List<dynamic>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse(DatabaseConfig.getCoursesUrl())).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['courses'] ?? [];
      }
    } catch (e) {
      debugPrint("Get courses error: $e");
    }
    return [];
  }

  // 6. 獲取學生已報名課程 (get_my_courses.php)
  static Future<List<dynamic>> getStudentCourses(String mId) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/get_my_courses.php?mId=$mId';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['courses'] ?? [];
      }
    } catch (e) {
      debugPrint("Get student courses error: $e");
    }
    return [];
  }

  // 7. 獲取老師開設課程 (get_teacher_courses.php)
  static Future<List<dynamic>> getTeacherCourses(String mId) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/get_teacher_courses.php?mId=$mId';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['courses'] ?? [];
      }
    } catch (e) {
      debugPrint("Get teacher courses error: $e");
    }
    return [];
  }

  // 8. 建立課程 (create_course.php)
  static Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/create_course.php';
      final response = await http.post(Uri.parse(url), body: data);
      final resData = jsonDecode(response.body);
      return resData['success'] == true;
    } catch (e) {
      debugPrint("Create course error: $e");
      return false;
    }
  }

  // 9. 報名課程 (enroll_course.php)
  static Future<Map<String, dynamic>> enrollCourse({
    required String memberId,
    required String courseId,
    required double price,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(DatabaseConfig.enrollUrl()),
        body: {'mId': memberId, 'cId': courseId, 'amount': price.toString()},
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server Error'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // 10. 獲取課程內容/影片 (get_course_content.php)
  static Future<Map<String, dynamic>> getCourseContent(String cId, String mId) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/get_course_content.php?cId=$cId&mId=$mId';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Get content error: $e");
    }
    return {'success': false, 'isEnrolled': false, 'lessons': []};
  }

  // 11. 測試所有 URL (連線診斷用)
  static Future<Map<String, dynamic>> testAllUrls() async {
    // 簡單實作：測試首頁是否能連上
    try {
      final response = await http.get(Uri.parse(DatabaseConfig.baseUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return {'success': true, 'workingBaseUrl': DatabaseConfig.baseUrl, 'data': 'OK'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    return {'success': false, 'message': 'Connection failed'};
  }

  // --- 作業相關 API (新功能) ---

  static Future<List<dynamic>> getAssignments(String cId, {String? mId}) async {
    try {
      String url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/get_assignments.php?cId=$cId';
      if (mId != null) url += '&mId=$mId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['assignments'] ?? [];
      }
    } catch (e) { debugPrint("Err: $e"); }
    return [];
  }

  static Future<bool> createAssignment({
    required String cId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/create_assignment.php';
      final response = await http.post(Uri.parse(url), body: {
        'cId': cId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
      });
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getSubmissions(String aId) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/get_submissions.php?aId=$aId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['submissions'] ?? [];
      }
    } catch (e) { debugPrint("Err: $e"); }
    return [];
  }

  static Future<bool> submitAssignment(String aId, String mId, File file) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/submit_assignment.php';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['aId'] = aId;
      request.fields['mId'] = mId;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var json = jsonDecode(respStr);
        return json['success'] == true;
      }
    } catch (e) { debugPrint("Err: $e"); }
    return false;
  }
    // 刪除課程
  static Future<bool> deleteCourse(String cId) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/delete_course.php';
      final response = await http.post(Uri.parse(url), body: {'cId': cId});
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 新增 Lesson (影片章節)
  static Future<bool> addLesson({
    required String cId,
    required String lName,
    required String videoUrl,
    required String duration,
  }) async {
    try {
      final url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/add_lesson.php';
      final response = await http.post(Uri.parse(url), body: {
        'cId': cId,
        'lName': lName,
        'video': videoUrl,
        'duration': duration,
      });
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

}
