import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import '../config/database.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

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
            debugPrint("Register parse error: $e");
            return true; 
         }
      }
      return false;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    }
  }

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

  static Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      // Fix: Changed 'final' to 'const' because the string is a compile-time constant.
      const url = '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}/api/create_course.php';
      final response = await http.post(Uri.parse(url), body: data);
      final resData = jsonDecode(response.body);
      return resData['success'] == true;
    } catch (e) {
      debugPrint("Create course error: $e");
      return false;
    }
  }

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

  static Future<Map<String, dynamic>> testAllUrls() async { return {'success': false}; }
  static Future<Map<String, dynamic>> adminLogin({required String username, required String password}) async {
    return login(username: username, password: password, userType: 'ADMIN');
  }
}
