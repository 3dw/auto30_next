# 🗑️ 完整刪除互助旗和帳號功能指南

## 📋 Step 1: 專案架構和功能研究

### 🏗️ 專案運行架構

#### Firebase 後端服務
- **Firebase Authentication** - 管理用戶登入、註冊、密碼重設
- **Firebase Realtime Database** - 儲存用戶資料、互助旗狀態、配對記錄

#### 主要功能模組
1. **認證系統** (`lib/features/auth/`)
   - 支援 Google 登入和 Email/密碼登入
   - 用戶狀態管理

2. **個人資料系統** (`lib/features/profile/`)
   - 個人資料編輯和顯示
   - 位置選擇和地圖整合

3. **社交功能**
   - 地圖顯示附近用戶 (`lib/features/map/`)
   - 配對系統 (`lib/features/match/`)
   - QR 碼分享 (`lib/features/qr/`)

4. **狀態管理**
   - 互助旗狀態 (`lib/core/providers/flag_status_provider.dart`)
   - 主題設定 (`lib/core/providers/theme_provider.dart`)

---

## 📊 Step 2: 需要刪除的資料分析

### 🔥 Firebase Authentication
```
用戶帳號資料：
- User ID (uid)
- Email 地址
- 密碼（加密儲存）
- Google 帳號連結（如果有使用 Google 登入）
- 創建時間和最後登入時間
```

### 🗄️ Firebase Realtime Database
根據專案程式碼分析，需要刪除的資料位置：

#### 1. 主要用戶資料 (`/users/{uid}`)
```json
{
  "name": "用戶姓名",
  "email": "用戶信箱",
  "learner_birth": "出生年份",
  "learner_role": "身份（自學生/家長/教育工作者）",
  "learner_type": "自學型態",
  "learner_habit": "興趣愛好",
  "address": "所在地區",
  "latlngColumn": "地理位置座標",
  "connect_me": "聯絡方式",
  "site": "個人網站",
  "site2": "第二個個人網站",
  "note": "自我介紹",
  "share": "可分享技能",
  "ask": "想學習的技能",
  "price": "收費說明",
  "available_time": "有空時段",
  "oldest_child_birth": "最大孩子出生年",
  "youngest_child_birth": "最小孩子出生年",
  "flag_down": "互助旗狀態",
  "last_flag_update": "最後更新時間",
  "photoURL": "頭像網址",
  "uid": "用戶ID",
  "lastUpdate": "最後更新時間戳"
}
```

#### 2. 配對記錄 (`/matches/{uid}`)
```json
{
  "targetUserId1": {
    "liked": true,
    "timestamp": 1234567890,
    "matchScore": 85
  },
  "targetUserId2": {
    "liked": false,
    "timestamp": 1234567891,
    "matchScore": 72
  }
}
```

#### 3. 其他用戶的配對記錄中對該用戶的引用
```json
{
  "/matches/otherUserId/{deletedUserId}": "需要刪除的記錄"
}
```

### 💾 本地儲存 (SharedPreferences)
```
- flag_down: 互助旗狀態
- theme_mode: 主題設定
- 其他用戶偏好設定
```

---

## 🎓 Step 3: 給國一生的程式設計教學

### 📚 基礎概念解釋

#### 什麼是「刪除帳號」？
想像你在圖書館有一張借書證：
- **借書證** = Firebase Authentication 帳號
- **你的個人資料卡** = Firebase Database 中的用戶資料
- **你借過的書記錄** = 配對記錄、互動記錄

刪除帳號就是要把這三樣東西都清理乾淨！

#### 為什麼要分步驟刪除？
就像搬家一樣，你不能直接把房子炸掉，要：
1. 先整理物品（清理資料庫資料）
2. 退租（刪除 Firebase 帳號）
3. 清理痕跡（清除本地資料）

---

## 💻 Step 4: 程式碼實作

### 🔧 1. 創建帳號刪除服務

首先，我們創建一個專門處理帳號刪除的服務：

```dart
// lib/services/account_deletion_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
    
    try {
      // 步驟 1: 刪除 Realtime Database 中的用戶資料
      await _deleteUserData(uid);
      
      // 步驟 2: 刪除配對記錄
      await _deleteMatchingRecords(uid);
      
      // 步驟 3: 清理其他用戶配對記錄中的引用
      await _cleanupMatchingReferences(uid);
      
      // 步驟 4: 清除本地儲存
      await _clearLocalStorage();
      
      // 步驟 5: 刪除 Firebase Authentication 帳號
      await user.delete();
      
    } catch (e) {
      throw Exception('刪除帳號時發生錯誤: $e');
    }
  }

  /// 刪除用戶主要資料
  Future<void> _deleteUserData(String uid) async {
    await _database.child('users/$uid').remove();
  }

  /// 刪除用戶的配對記錄
  Future<void> _deleteMatchingRecords(String uid) async {
    await _database.child('matches/$uid').remove();
  }

  /// 清理其他用戶配對記錄中對該用戶的引用
  Future<void> _cleanupMatchingReferences(String uid) async {
    // 讀取所有配對記錄
    final matchesSnapshot = await _database.child('matches').get();
    
    if (matchesSnapshot.exists && matchesSnapshot.value != null) {
      final allMatches = Map<String, dynamic>.from(matchesSnapshot.value as Map);
      
      // 遍歷每個用戶的配對記錄
      for (final otherUserId in allMatches.keys) {
        if (otherUserId != uid) {
          final otherUserMatches = Map<String, dynamic>.from(allMatches[otherUserId]);
          
          // 如果其他用戶的配對記錄中有對該用戶的引用，就刪除
          if (otherUserMatches.containsKey(uid)) {
            await _database.child('matches/$otherUserId/$uid').remove();
          }
        }
      }
    }
  }

  /// 清除本地儲存資料
  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 清除所有相關的本地資料
    final keysToRemove = [
      'flag_down',
      'theme_mode',
      // 可以根據需要添加更多鍵值
    ];
    
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  /// 獲取將被刪除的資料摘要（讓用戶了解會刪除什麼）
  Future<Map<String, dynamic>> getDataSummary() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final uid = user.uid;
    final summary = <String, dynamic>{};

    try {
      // 獲取用戶資料
      final userSnapshot = await _database.child('users/$uid').get();
      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        summary['userData'] = {
          'name': userData['name'] ?? '未知',
          'email': userData['email'] ?? user.email,
          'address': userData['address'] ?? '未設定',
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
      summary['flagStatus'] = userSnapshot.exists 
          ? (Map<String, dynamic>.from(userSnapshot.value as Map)['flag_down'] ?? false ? '已降下' : '已升起')
          : '未知';

    } catch (e) {
      summary['error'] = '無法讀取資料摘要: $e';
    }

    return summary;
  }
}
```

### 🎨 2. 在個人資料頁面添加刪除按鈕

修改 `lib/features/profile/profile_screen.dart`：

```dart
// 在保存按鈕下方添加刪除按鈕
const SizedBox(height: 16),

// 🗑️ 完整刪除互助旗和帳號按鈕
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: _showDeleteAccountDialog,
    icon: const Icon(Icons.delete_forever),
    label: const Text('完整刪除互助旗和帳號'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
),
```

### 🛡️ 3. 添加安全確認對話框

在 `ProfileScreen` 類別中添加這些方法：

```dart
// 引入帳號刪除服務
import 'package:auto30_next/services/account_deletion_service.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  // ... 現有程式碼 ...
  
  final AccountDeletionService _deletionService = AccountDeletionService();

  /// 顯示刪除帳號確認對話框
  void _showDeleteAccountDialog() async {
    // 先獲取要刪除的資料摘要
    final dataSummary = await _deletionService.getDataSummary();
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // 不能點外面關閉
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('⚠️ 危險操作'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '你即將完整刪除你的帳號和所有資料，這個操作無法復原！',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('📋 將會刪除的資料：'),
                const SizedBox(height: 8),
                
                // 顯示資料摘要
                if (dataSummary['userData'] != null) ...[
                  Text('👤 姓名：${dataSummary['userData']['name']}'),
                  Text('📧 信箱：${dataSummary['userData']['email']}'),
                  Text('📍 地區：${dataSummary['userData']['address']}'),
                  Text('📅 註冊時間：${dataSummary['userData']['registrationDate']}'),
                ],
                Text('🤝 配對記錄：${dataSummary['matchCount']} 筆'),
                Text('🚩 互助旗狀態：${dataSummary['flagStatus']}'),
                
                const SizedBox(height: 16),
                const Text(
                  '⚠️ 注意：刪除後你將無法：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• 登入這個帳號'),
                const Text('• 恢復任何資料'),
                const Text('• 查看過往的配對記錄'),
                const Text('• 使用相同信箱重新註冊（可能需要等待）'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showFinalConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('我了解，繼續刪除'),
            ),
          ],
        );
      },
    );
  }

  /// 最終確認對話框
  void _showFinalConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🔒 最後確認'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '請再次確認你真的要刪除帳號。',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('這是最後一次機會可以取消！'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我反悔了，取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _executeAccountDeletion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('確定刪除帳號'),
            ),
          ],
        );
      },
    );
  }

  /// 執行帳號刪除
  Future<void> _executeAccountDeletion() async {
    // 顯示載入對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在刪除帳號...'),
            Text('請稍候，不要關閉應用程式'),
          ],
        ),
      ),
    );

    try {
      await _deletionService.deleteUserAccount();
      
      if (mounted) {
        Navigator.of(context).pop(); // 關閉載入對話框
        
        // 顯示成功訊息
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✅ 刪除成功'),
            content: const Text('你的帳號和所有資料已經完全刪除。\n\n應用程式將會關閉。'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // 可以使用 SystemNavigator.pop() 關閉應用程式
                  // 或者導航到登入頁面
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', 
                    (route) => false,
                  );
                },
                child: const Text('確定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 關閉載入對話框
        
        // 顯示錯誤訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('刪除失敗：$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
```

### 🔐 4. 處理重新認證（安全考量）

對於敏感操作如刪除帳號，Firebase 可能要求重新認證：

```dart
/// 重新認證用戶（如果需要）
Future<void> _reauthenticateUser() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('用戶未登入');

  // 如果是 Google 登入用戶
  if (user.providerData.any((info) => info.providerId == 'google.com')) {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    }
  } else {
    // 如果是 Email/密碼用戶，需要提示用戶輸入密碼
    // 這裡可以顯示一個對話框讓用戶輸入密碼
    throw Exception('需要重新輸入密碼以確認身份');
  }
}
```

---

## 🧪 Step 5: 測試建議

### 🔬 測試步驟
1. **創建測試帳號**：用不重要的信箱註冊
2. **填寫完整資料**：姓名、地區、興趣等
3. **進行一些配對**：讓系統產生配對記錄
4. **執行刪除功能**：確認所有步驟都正常
5. **驗證刪除結果**：
   - 無法用相同帳號登入
   - Firebase Console 中確認資料已清除
   - 其他用戶看不到你的資料

### 🛡️ 安全考量
- 刪除前必須重新認證
- 多重確認對話框
- 清楚說明刪除後果
- 提供資料匯出選項（可選）

---

## 📚 Step 6: 學習重點總結

### 🎯 這個功能教會你什麼？

1. **資料庫設計思維**：了解資料間的關聯性
2. **用戶體驗設計**：如何設計安全的刪除流程
3. **錯誤處理**：如何優雅地處理可能的失敗情況
4. **非同步程式設計**：使用 async/await 處理複雜操作
5. **狀態管理**：如何在刪除過程中管理 UI 狀態

### 🔍 進階思考問題
1. 如果刪除過程中網路斷線怎麼辦？
2. 如何實作「軟刪除」（標記為刪除但不真的刪除）？
3. 如何讓用戶在刪除前匯出自己的資料？
4. 如何處理刪除帳號後其他用戶對話記錄中的引用？

---

## ⚠️ 重要提醒

1. **測試環境**：一定要在測試環境充分測試
2. **備份機制**：考慮實作資料備份功能
3. **法律合規**：確保符合 GDPR 等資料保護法規
4. **用戶教育**：清楚告知用戶刪除的後果

這個功能涉及用戶的重要資料，實作時要特別小心謹慎！🛡️ 