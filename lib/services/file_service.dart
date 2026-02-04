// lib/services/file_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/database.dart'; // 確保能讀取 DatabaseConfig

class FileService {
  // [關鍵修正]：統一使用 DatabaseConfig，不再硬編碼
  static String get baseUrl => '${DatabaseConfig.baseUrl}${DatabaseConfig.projectPath}';
  static const String uploadEndpoint = '/api/upload_file.php';
  static const String getFilesEndpoint = '/api/get_files.php';

  Future<String> _getPrivateDownloadPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<Map<String, dynamic>> downloadToPrivateDirectory(String fileUrl, String fileName) async {
    try {
      final downloadDir = await _getPrivateDownloadPath();
      final safeFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final savePath = path.join(downloadDir, safeFileName);
      
      final response = await http.get(Uri.parse(fileUrl));
      
      if (response.statusCode == 200) {
        await File(savePath).writeAsBytes(response.bodyBytes);
        return {'success': true, 'path': savePath};
      } else {
        return {'success': false, 'error': 'Download failed: HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Download error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    File file, 
    String fileName, {
    String userId = 'unknown_user',
    List<String> courseIds = const [],
  }) async {
    try {
      String url = '$baseUrl$uploadEndpoint';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
      request.fields['user_id'] = userId;
      request.fields['description'] = 'Uploaded from Flutter app';
      if (courseIds.isNotEmpty) {
        request.fields['course_ids'] = courseIds.join(',');
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      return json.decode(responseData);

    } catch (e) {
      return {'success': false, 'error': 'Upload failed: $e'};
    }
  }

  Future<Map<String, dynamic>> getFiles({String? userId, String? courseId}) async {
    try {
      String url = '$baseUrl$getFilesEndpoint?';
      List<String> params = [];
      if (userId != null && userId.isNotEmpty) params.add('user_id=$userId');
      if (courseId != null && courseId.isNotEmpty) params.add('course_id=$courseId');
      url += params.join('&');

      var response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'HTTP ${response.statusCode}', 'files': []};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to get files: $e', 'files': []};
    }
  }

  String formatFileSize(dynamic bytes) {
    if (bytes is! num) return '0 bytes';
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '$bytes bytes';
  }
}
