import 'package:flutter/foundation.dart';

class AppConfig {
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '270389952986-ieilk8oot9an611crndg2ijobv88pokt.apps.googleusercontent.com',
  );

  // 其他配置項可以加在這裡
  static const String appName = 'Auto30 Next';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl =
      'https://api.auto30.com'; // Replace with your actual API URL

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePushNotifications = true;

  // Cache configuration
  static const int cacheDuration = 7; // days
  static const int maxCacheSize = 100; // MB

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/user/profile';
  static const String settingsEndpoint = '/user/settings';

  // Social login configuration
  static const bool enableGoogleSignIn = true;
  static const bool enableAppleSignIn = true;

  // Theme configuration
  static const bool useSystemTheme = true;
  static const String defaultLocale = 'en';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // 環境相關配置
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isWeb => kIsWeb;
} 