import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyMId = 'mId';       // 改為 mId
  static const String _keyFName = 'fName';   // 改為 fName
  static const String _keyNName = 'nName';   // 改為 nName
  static const String _keyMType = 'mType';   // 改為 mType
  static const String _keyEmail = 'email';
  
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMId, userInfo['mId']?.toString() ?? '');
    await prefs.setString(_keyFName, userInfo['fName'] ?? '');
    await prefs.setString(_keyNName, userInfo['nName'] ?? '');
    await prefs.setString(_keyMType, userInfo['mType'] ?? 'STUDENT');
    await prefs.setString(_keyEmail, userInfo['email'] ?? '');
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mId': prefs.getString(_keyMId) ?? '',
      'fName': prefs.getString(_keyFName) ?? '',
      'nName': prefs.getString(_keyNName) ?? '',
      'mType': prefs.getString(_keyMType) ?? 'STUDENT',
      'email': prefs.getString(_keyEmail) ?? '',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有
  }
}
