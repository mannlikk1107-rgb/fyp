import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class UserProvider extends ChangeNotifier {
  double _balance = 0.0;
  String _mId = '';
  String _name = '';
  String _email = '';
  bool _isLoading = true;

  double get balance => _balance;
  String get mId => _mId;
  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;

  // 初始化用戶數據 (App 啟動時呼叫)
  Future<void> loadUser() async {
    _isLoading = true;
    // 不要在這裡 notifyListeners，避免 build 期間更新
    
    final info = await LocalStorage.getUserInfo();
    _mId = info['mId'] ?? '';
    _name = info['fName'] ?? 'Guest';
    _email = info['email'] ?? '';

    if (_mId.isNotEmpty) {
      await refreshBalance();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新餘額 (在購買課程後呼叫)
  Future<void> refreshBalance() async {
    if (_mId.isNotEmpty) {
      _balance = await ApiService.getWalletBalance(_mId);
    }
    _isLoading = false;
    notifyListeners();
  }

  // 登出時清除
  void clearUser() {
    _mId = '';
    _balance = 0.0;
    _name = '';
    notifyListeners();
  }
}
