import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseTest {
  /// 測試 Firebase Auth 連接
  static Future<Map<String, dynamic>> testAuth() async {
    final result = <String, dynamic>{};
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      result['auth_connected'] = true;
      result['user_logged_in'] = user != null;
      result['user_id'] = user?.uid ?? 'null';
      result['user_email'] = user?.email ?? 'null';
      result['user_email_verified'] = user?.emailVerified ?? false;
      
      // 測試重新認證
      if (user != null) {
        try {
          await user.reload();
          result['user_reload_success'] = true;
        } catch (e) {
          result['user_reload_success'] = false;
          result['user_reload_error'] = e.toString();
        }
      }
      
    } catch (e) {
      result['auth_connected'] = false;
      result['auth_error'] = e.toString();
    }
    
    return result;
  }

  /// 測試 Firebase Realtime Database 連接
  static Future<Map<String, dynamic>> testDatabase() async {
    final result = <String, dynamic>{};
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        result['database_test_skipped'] = true;
        result['reason'] = 'no_user_logged_in';
        return result;
      }

      final ref = FirebaseDatabase.instance.ref();
      
      // 測試讀取權限
      try {
        final snapshot = await ref.child('users/${user.uid}').get();
        result['read_permission'] = true;
        result['user_data_exists'] = snapshot.exists;
        
        if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>?;
          result['flag_down_exists'] = userData?.containsKey('flag_down') ?? false;
          result['flag_down_value'] = userData?['flag_down'];
        }
      } catch (e) {
        result['read_permission'] = false;
        result['read_error'] = e.toString();
      }

      // 測試寫入權限
      try {
        final testRef = ref.child('users/${user.uid}/test_write');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        await testRef.set(timestamp);
        result['write_permission'] = true;
        
        // 驗證寫入是否成功
        final readBack = await testRef.get();
        result['write_verification'] = readBack.value == timestamp;
        
        // 清理測試數據
        await testRef.remove();
        result['cleanup_success'] = true;
        
      } catch (e) {
        result['write_permission'] = false;
        result['write_error'] = e.toString();
      }

      // 測試 flag_down 特定操作
      try {
        final flagRef = ref.child('users/${user.uid}/flag_down');
        
        // 嘗試寫入 flag_down
        await flagRef.set(true);
        result['flag_down_write'] = true;
        
        // 讀取回來驗證
        final flagSnapshot = await flagRef.get();
        result['flag_down_read_back'] = flagSnapshot.value;
        result['flag_down_consistent'] = flagSnapshot.value == true;
        
        // 嘗試切換狀態
        await flagRef.set(false);
        final flagSnapshot2 = await flagRef.get();
        result['flag_down_toggle'] = flagSnapshot2.value == false;
        
      } catch (e) {
        result['flag_down_test_error'] = e.toString();
      }

    } catch (e) {
      result['database_connected'] = false;
      result['database_error'] = e.toString();
    }
    
    return result;
  }

  /// 完整系統測試
  static Future<Map<String, dynamic>> fullTest() async {
    final result = <String, dynamic>{};
    
    result['test_timestamp'] = DateTime.now().toIso8601String();
    result['platform'] = defaultTargetPlatform.name;
    
    // 測試認證
    final authResult = await testAuth();
    result['auth'] = authResult;
    
    // 測試數據庫
    final dbResult = await testDatabase();
    result['database'] = dbResult;
    
    // 綜合評估
    result['overall_health'] = _calculateHealth(authResult, dbResult);
    
    return result;
  }

  /// 計算系統健康狀態
  static String _calculateHealth(Map<String, dynamic> authResult, Map<String, dynamic> dbResult) {
    if (authResult['auth_connected'] != true) {
      return 'AUTH_FAILED';
    }
    
    if (authResult['user_logged_in'] != true) {
      return 'NOT_LOGGED_IN';
    }
    
    if (dbResult['read_permission'] != true) {
      return 'NO_READ_PERMISSION';
    }
    
    if (dbResult['write_permission'] != true) {
      return 'NO_WRITE_PERMISSION';
    }
    
    if (dbResult['flag_down_write'] != true) {
      return 'FLAG_WRITE_FAILED';
    }
    
    if (dbResult['flag_down_consistent'] != true) {
      return 'FLAG_READ_INCONSISTENT';
    }
    
    return 'HEALTHY';
  }

  /// 打印測試結果
  static void printTestResult(Map<String, dynamic> result) {
    debugPrint('=== Firebase 完整測試結果 ===');
    _printMapRecursive(result, 0);
    debugPrint('========================');
  }

  static void _printMapRecursive(Map<String, dynamic> map, int indent) {
    final prefix = '  ' * indent;
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        debugPrint('$prefix$key:');
        _printMapRecursive(value, indent + 1);
      } else {
        debugPrint('$prefix$key: $value');
      }
    });
  }

  /// 常見問題的修復建議
  static List<String> getFixSuggestions(String health) {
    switch (health) {
      case 'AUTH_FAILED':
        return [
          '檢查 Firebase 配置是否正確',
          '確認網絡連接正常',
          '檢查 firebase_options.dart 設定',
        ];
      
      case 'NOT_LOGGED_IN':
        return [
          '用戶需要重新登入',
          '檢查登入狀態是否過期',
          '確認認證流程正常工作',
        ];
      
      case 'NO_READ_PERMISSION':
        return [
          '檢查 Firebase Database 安全規則',
          '確認用戶有讀取權限',
          '檢查數據庫 URL 是否正確',
        ];
      
      case 'NO_WRITE_PERMISSION':
        return [
          '檢查 Firebase Database 安全規則',
          '確認用戶有寫入權限',
          '檢查認證狀態是否正確',
        ];
      
      case 'FLAG_WRITE_FAILED':
        return [
          '檢查 flag_down 欄位的寫入權限',
          '確認數據結構設定正確',
          '檢查網絡連接穩定性',
        ];
      
      case 'FLAG_READ_INCONSISTENT':
        return [
          '可能存在網絡延遲問題',
          '檢查 Firebase 同步狀態',
          '嘗試重新連接數據庫',
        ];
      
      default:
        return ['系統運行正常'];
    }
  }
} 