import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileService {
  static const String baseUrl = 'http://3.107.205.191/Research/Web/TestFYP';
  static const String uploadEndpoint = '/api/upload_file.php';
  static const String getFilesEndpoint = '/api/get_files.php';
  static const String deleteEndpoint = '/api/delete_file.php';

  Future<String> _getPrivateDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadPath = '${directory.path}/Downloads';
    final dir = Directory(downloadPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return downloadPath;
  }

  Future<Map<String, dynamic>> downloadToPrivateDirectory(String fileUrl, String fileName) async {
    try {
      final downloadDir = await _getPrivateDownloadPath();
      final safeFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final savePath = path.join(downloadDir, safeFileName);
      
      final response = await http.get(Uri.parse(fileUrl));
      
      if (response.statusCode == 200) {
        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        
        if (await file.exists()) {
          return {'success': true, 'path': savePath};
        } else {
          return {'success': false, 'error': 'File not created'};
        }
      } else {
        return {'success': false, 'error': 'Download failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Download error: $e'};
    }
  }

  // --- [MODIFIED] uploadFile method ---
  Future<Map<String, dynamic>> uploadFile(
    File file, 
    String fileName, {
    String userId = 'unknown_user',
    List<String> courseIds = const [], // Changed to a list
  }) async {
    try {
      String url = '$baseUrl$uploadEndpoint';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
      
      request.fields['user_id'] = userId;
      request.fields['description'] = 'Uploaded from Flutter app';
      
      // [KEY CHANGE] Join the list into a comma-separated string to send to PHP
      if (courseIds.isNotEmpty) {
        request.fields['course_ids'] = courseIds.join(',');
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);
      return result;
    } catch (e) {
      return {'success': false, 'error': 'Upload failed: $e'};
    }
  }

  Future<Map<String, dynamic>> getFiles({String? userId}) async {
    try {
      String url = '$baseUrl$getFilesEndpoint';
      if (userId != null) {
        url += '?user_id=$userId';
      }
      var response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to get files: $e', 'files': []};
    }
  }

  String formatFileSize(int bytes) {
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '$bytes bytes';
  }
}
