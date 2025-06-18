import 'package:flutter/foundation.dart';

class AppConfig {
  // 使用環境變數來配置 Google Client ID
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR-GOOGLE-CLIENT-ID',
  );

  // 其他配置項可以加在這裡
  static const String appName = 'Auto30 Next';
  static const String appVersion = '1.0.0';
  
  // 環境相關配置
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isWeb => kIsWeb;
} 