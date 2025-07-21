import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:auto30_next/core/config/app_config.dart';

class AccountDeletionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// 完整刪除用戶帳號和所有相關資料
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('沒有登入的用戶');
    }

    final uid = user.uid;
    debugPrint('開始刪除用戶帳號: $uid');
    
    try {
      // 步驟 1: 嘗試重新認證用戶（安全考量）
      try {
        await _reauthenticateUser();
        debugPrint('用戶重新認證成功');
      } catch (e) {
        debugPrint('重新認證失敗，但繼續刪除流程: $e');
        // 重新認證失敗時，我們仍然繼續刪除流程
        // 因為用戶已經在當前會話中登入了
      }
      
      // 步驟 2: 刪除 Realtime Database 中的用戶資料
      await _deleteUserData(uid);
      debugPrint('用戶資料已從資料庫刪除');
      
      // 步驟 3: 刪除配對記錄
      await _deleteMatchingRecords(uid);
      debugPrint('配對記錄已刪除');
      
      // 步驟 4: 清理其他用戶配對記錄中的引用
      await _cleanupMatchingReferences(uid);
      debugPrint('其他用戶配對記錄中的引用已清理');
      
      // 步驟 5: 清除本地儲存
      await _clearLocalStorage();
      debugPrint('本地儲存已清除');
      
      // 步驟 6: 刪除 Firebase Authentication 帳號
      try {
        await user.delete();
        debugPrint('Firebase Authentication 帳號已刪除');
      } catch (e) {
        debugPrint('刪除 Firebase Authentication 帳號時發生錯誤: $e');
        // 如果是因為需要重新認證而失敗，我們提供更友善的錯誤訊息
        if (e.toString().contains('requires-recent-login')) {
          throw Exception('為了安全考量，刪除帳號需要重新登入。請重新登入後再試。');
        }
        rethrow;
      }
      
      debugPrint('帳號刪除完成');
    } catch (e) {
      debugPrint('刪除帳號時發生錯誤: $e');
      throw Exception('刪除帳號時發生錯誤: $e');
    }
  }

  /// 重新認證用戶（安全考量）
  Future<void> _reauthenticateUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用戶未登入');

    // 檢查用戶的登入方式
    final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
    
    if (isGoogleUser) {
      // Google 登入用戶的重新認證
      try {
        // 使用配置的 Google Client ID
        final googleSignIn = GoogleSignIn(
          clientId: AppConfig.googleClientId,
        );
        
        // 先登出再重新登入以確保重新認證
        await googleSignIn.signOut();
        final googleUser = await googleSignIn.signIn();
        
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          debugPrint('Google 重新認證成功');
        } else {
          throw Exception('Google 重新認證失敗：用戶取消登入');
        }
      } catch (e) {
        debugPrint('Google 重新認證詳細錯誤: $e');
        throw Exception('Google 重新認證失敗: $e');
      }
    } else {
      // Email/密碼用戶需要重新輸入密碼
      // 這個部分需要在 UI 層面處理，讓用戶輸入密碼
      throw Exception('需要重新輸入密碼以確認身份。請在 UI 中實作密碼輸入對話框。');
    }
  }

  /// 刪除用戶主要資料
  Future<void> _deleteUserData(String uid) async {
    try {
      // 先檢查用戶資料是否存在
      final userSnapshot = await _database.child('users/$uid').get();
      
      if (userSnapshot.exists) {
        debugPrint('找到用戶資料，嘗試刪除');
        await _database.child('users/$uid').remove();
        debugPrint('用戶資料刪除成功');
      } else {
        debugPrint('沒有找到用戶資料，跳過刪除');
      }
    } catch (e) {
      debugPrint('刪除用戶資料時發生錯誤: $e');
      // 用戶資料刪除失敗是比較嚴重的問題，但我們仍然記錄並拋出異常
      throw Exception('刪除用戶資料失敗: $e');
    }
  }

  /// 刪除用戶的配對記錄
  Future<void> _deleteMatchingRecords(String uid) async {
    try {
      // 先檢查配對記錄是否存在
      final matchesSnapshot = await _database.child('matches/$uid').get();
      
      if (matchesSnapshot.exists && matchesSnapshot.value != null) {
        debugPrint('找到配對記錄，嘗試刪除');
        await _database.child('matches/$uid').remove();
        debugPrint('配對記錄刪除成功');
      } else {
        debugPrint('沒有找到配對記錄，跳過刪除');
      }
    } catch (e) {
      debugPrint('刪除配對記錄時發生權限或其他錯誤: $e');
      // 如果是權限問題，我們記錄但不拋出異常，讓其他清理步驟繼續
      if (e.toString().contains('permission-denied')) {
        debugPrint('權限不足，無法刪除配對記錄，但繼續其他清理步驟');
      } else {
        throw Exception('刪除配對記錄失敗: $e');
      }
    }
  }

  /// 清理其他用戶配對記錄中對該用戶的引用
  Future<void> _cleanupMatchingReferences(String uid) async {
    try {
      // 讀取所有配對記錄
      final matchesSnapshot = await _database.child('matches').get();
      
      if (matchesSnapshot.exists && matchesSnapshot.value != null) {
        final allMatches = Map<String, dynamic>.from(matchesSnapshot.value as Map);
        
        // 遍歷每個用戶的配對記錄
        for (final otherUserId in allMatches.keys) {
          if (otherUserId != uid) {
            try {
              final otherUserMatches = Map<String, dynamic>.from(allMatches[otherUserId]);
              
              // 如果其他用戶的配對記錄中有對該用戶的引用，就嘗試刪除
              if (otherUserMatches.containsKey(uid)) {
                await _database.child('matches/$otherUserId/$uid').remove();
                debugPrint('已從用戶 $otherUserId 的配對記錄中刪除對 $uid 的引用');
              }
            } catch (e) {
              debugPrint('清理用戶 $otherUserId 的配對記錄引用時發生錯誤: $e');
              // 如果是權限問題，記錄但繼續處理其他用戶
              if (e.toString().contains('permission-denied')) {
                debugPrint('權限不足，無法清理用戶 $otherUserId 的配對記錄引用');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('讀取配對記錄時發生錯誤: $e');
      // 如果是權限問題，我們記錄但不拋出異常
      if (e.toString().contains('permission-denied')) {
        debugPrint('權限不足，無法讀取所有配對記錄進行清理');
      } else {
        throw Exception('清理配對記錄引用失敗: $e');
      }
    }
  }

  /// 清除本地儲存資料
  Future<void> _clearLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 清除所有相關的本地資料
      final keysToRemove = [
        'flag_down',
        'theme_mode',
        'user_preferences',
        'last_sync',
        // 可以根據需要添加更多鍵值
      ];
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
        debugPrint('已清除本地儲存鍵值: $key');
      }
    } catch (e) {
      throw Exception('清除本地儲存失敗: $e');
    }
  }

  /// 獲取將被刪除的資料摘要（讓用戶了解會刪除什麼）
  Future<Map<String, dynamic>> getDataSummary() async {
    final user = _auth.currentUser;
    if (user == null) return {'error': '用戶未登入'};

    final uid = user.uid;
    final summary = <String, dynamic>{};

    try {
      // 獲取用戶資料
      final userSnapshot = await _database.child('users/$uid').get();
      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        summary['userData'] = {
          'name': userData['name'] ?? '未知',
          'email': userData['email'] ?? user.email,
          'address': userData['address'] ?? '未設定',
          'learnerRole': userData['learner_role'] ?? '未知',
          'registrationDate': user.metadata.creationTime?.toString() ?? '未知',
        };
      } else {
        summary['userData'] = {
          'name': '未設定',
          'email': user.email ?? '未知',
          'address': '未設定',
          'learnerRole': '未知',
          'registrationDate': user.metadata.creationTime?.toString() ?? '未知',
        };
      }

      // 獲取配對記錄數量
      final matchesSnapshot = await _database.child('matches/$uid').get();
      if (matchesSnapshot.exists && matchesSnapshot.value != null) {
        final matches = Map<String, dynamic>.from(matchesSnapshot.value as Map);
        summary['matchCount'] = matches.length;
      } else {
        summary['matchCount'] = 0;
      }

      // 獲取互助旗狀態
      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        final flagDown = userData['flag_down'] as bool? ?? false;
        summary['flagStatus'] = flagDown ? '已降下' : '已升起';
      } else {
        summary['flagStatus'] = '未知';
      }

      // 檢查登入方式
      final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
      summary['loginMethod'] = isGoogleUser ? 'Google 帳號' : 'Email/密碼';

      // 獲取帳號創建時間
      summary['accountAge'] = user.metadata.creationTime != null 
          ? DateTime.now().difference(user.metadata.creationTime!).inDays
          : 0;

    } catch (e) {
      summary['error'] = '無法讀取資料摘要: $e';
      debugPrint('獲取資料摘要時發生錯誤: $e');
    }

    return summary;
  }

  /// 檢查是否需要重新認證
  bool requiresReauthentication() {
    final user = _auth.currentUser;
    if (user == null) return false;

    // 檢查最後登入時間，如果超過一定時間就需要重新認證
    final lastSignInTime = user.metadata.lastSignInTime;
    if (lastSignInTime != null) {
      final timeSinceLastSignIn = DateTime.now().difference(lastSignInTime);
      return timeSinceLastSignIn.inMinutes > 5; // 5分鐘內不需要重新認證
    }
    
    return true;
  }

  /// 驗證用戶是否有權限刪除帳號
  Future<bool> canDeleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // 檢查用戶是否為匿名用戶
      if (user.isAnonymous) {
        return false; // 匿名用戶不能刪除帳號
      }

      // 檢查用戶是否已驗證 email
      if (!user.emailVerified && user.email != null) {
        // 如果是 email 用戶但未驗證，可能需要先驗證
        debugPrint('用戶 email 未驗證，但允許刪除帳號');
      }

      return true;
    } catch (e) {
      debugPrint('檢查刪除權限時發生錯誤: $e');
      return false;
    }
  }

  /// 檢查 Firebase 資料庫權限
  Future<Map<String, bool>> checkDatabasePermissions() async {
    final user = _auth.currentUser;
    final permissions = <String, bool>{};
    
    if (user == null) {
      return {
        'userDataRead': false,
        'userDataWrite': false,
        'matchesRead': false,
        'matchesWrite': false,
      };
    }

    final uid = user.uid;

    // 檢查用戶資料讀取權限
    try {
      await _database.child('users/$uid').get();
      permissions['userDataRead'] = true;
    } catch (e) {
      permissions['userDataRead'] = false;
      debugPrint('用戶資料讀取權限檢查失敗: $e');
    }

    // 檢查用戶資料寫入權限
    try {
      await _database.child('users/$uid/test_write').set(DateTime.now().millisecondsSinceEpoch);
      await _database.child('users/$uid/test_write').remove();
      permissions['userDataWrite'] = true;
    } catch (e) {
      permissions['userDataWrite'] = false;
      debugPrint('用戶資料寫入權限檢查失敗: $e');
    }

    // 檢查配對記錄讀取權限
    try {
      await _database.child('matches/$uid').get();
      permissions['matchesRead'] = true;
    } catch (e) {
      permissions['matchesRead'] = false;
      debugPrint('配對記錄讀取權限檢查失敗: $e');
    }

    // 檢查配對記錄寫入權限
    try {
      await _database.child('matches/$uid/test_write').set(DateTime.now().millisecondsSinceEpoch);
      await _database.child('matches/$uid/test_write').remove();
      permissions['matchesWrite'] = true;
    } catch (e) {
      permissions['matchesWrite'] = false;
      debugPrint('配對記錄寫入權限檢查失敗: $e');
    }

    return permissions;
  }

  /// 簡化版刪除帳號（跳過重新認證，僅用於測試）
  Future<void> deleteUserAccountSimple() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('沒有登入的用戶');
    }

    final uid = user.uid;
    debugPrint('開始簡化版刪除用戶帳號: $uid');
    
    try {
      // 直接刪除資料庫資料，不進行重新認證
      await _deleteUserData(uid);
      debugPrint('用戶資料已從資料庫刪除');
      
      await _deleteMatchingRecords(uid);
      debugPrint('配對記錄已刪除');
      
      await _cleanupMatchingReferences(uid);
      debugPrint('其他用戶配對記錄中的引用已清理');
      
      await _clearLocalStorage();
      debugPrint('本地儲存已清除');
      
      // 嘗試刪除 Firebase Authentication 帳號
      // 如果失敗就提供友善的錯誤訊息
      try {
        await user.delete();
        debugPrint('Firebase Authentication 帳號已刪除');
      } catch (e) {
        if (e.toString().contains('requires-recent-login')) {
          throw Exception('帳號資料已清除，但需要重新登入才能完全刪除 Firebase 帳號。請重新登入後再次嘗試。');
        }
        throw Exception('帳號資料已清除，但刪除 Firebase 帳號時發生錯誤: $e');
      }
      
      debugPrint('簡化版帳號刪除完成');
    } catch (e) {
      debugPrint('簡化版刪除帳號時發生錯誤: $e');
      rethrow;
    }
  }
} 