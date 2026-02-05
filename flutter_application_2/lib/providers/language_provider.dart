import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/app_strings.dart'; 

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('zh') : const Locale('en');
    notifyListeners();
  }

  // 這裡呼叫 AppStrings 應該就不會報錯了
  String t(String key) => AppStrings.tr(_locale.languageCode, key);
}
