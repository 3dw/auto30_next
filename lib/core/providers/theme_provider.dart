import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // 如果是系統模式，根據系統設定判斷
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      // 如果是系統模式，根據系統設定判斷
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }
  
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  String get themeModeText {
    switch (_themeMode) {
      case ThemeMode.light:
        return '白天模式';
      case ThemeMode.dark:
        return '黑夜模式';
      case ThemeMode.system:
        return '跟隨系統';
    }
  }
  
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  // 從本地儲存載入主題設定
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0; // 預設為系統模式
      
      switch (themeModeIndex) {
        case 0:
          _themeMode = ThemeMode.system;
          break;
        case 1:
          _themeMode = ThemeMode.light;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('載入主題設定時發生錯誤: $e');
    }
  }

  // 儲存主題設定到本地
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeModeIndex;
      
      switch (_themeMode) {
        case ThemeMode.system:
          themeModeIndex = 0;
          break;
        case ThemeMode.light:
          themeModeIndex = 1;
          break;
        case ThemeMode.dark:
          themeModeIndex = 2;
          break;
      }
      
      await prefs.setInt('theme_mode', themeModeIndex);
    } catch (e) {
      debugPrint('儲存主題設定時發生錯誤: $e');
    }
  }

  // 設定主題模式
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
      await _saveThemeMode();
    }
  }

  // 切換到下一個主題模式
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  // 直接設定為白天模式
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  // 直接設定為黑夜模式
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  // 設定為跟隨系統
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
} 