# 🔐 Firebase 安全規則配置指南

## 🚨 當前問題

你遇到的錯誤：
```
[firebase_database/permission-denied] PERMISSION_DENIED: Permission denied
```

這表示 Firebase Realtime Database 的安全規則限制了對 `matches` 路徑的刪除操作。

## 📋 問題分析

### 🔍 權限檢查結果
根據程式碼執行的權限檢查，可能的情況：
- ✅ **用戶資料 (`/users/{uid}`)**: 通常有完整權限
- ❌ **配對記錄 (`/matches/{uid}`)**: 可能缺少刪除權限

### 🎯 常見的安全規則問題
1. **只允許讀取，不允許刪除**
2. **需要特定條件才能刪除**
3. **完全禁止對 matches 路徑的寫入操作**

## 🛠️ 解決方案

### 方案 1: 修改 Firebase 安全規則（推薦）

#### 步驟 1: 前往 Firebase Console
1. 打開 [Firebase Console](https://console.firebase.google.com)
2. 選擇你的專案 `shackhand-autolearn`
3. 在左側選單選擇 "Realtime Database"
4. 點擊 "規則" 標籤

#### 步驟 2: 查看當前規則
當前的安全規則可能類似：
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "matches": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": false  // ❌ 這裡可能禁止了寫入
      }
    }
  }
}
```

#### 步驟 3: 修改規則以允許刪除
建議的安全規則：
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "matches": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      },
      // 允許用戶刪除其他人配對記錄中對自己的引用
      "$otherUid": {
        "$currentUid": {
          ".write": "auth != null && auth.uid == $currentUid"
        }
      }
    }
  }
}
```

### 方案 2: 更寬鬆的規則（僅用於開發測試）
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
⚠️ **注意**: 這個規則太寬鬆，不適合生產環境！

### 方案 3: 完整的生產級規則
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('flag_down').val() != true)",
        ".write": "auth != null && auth.uid == $uid",
        ".validate": "newData.hasChildren(['name', 'email'])"
      }
    },
    "matches": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid",
        "$targetUid": {
          ".validate": "newData.hasChildren(['liked', 'timestamp'])"
        }
      }
    }
  }
}
```

## 🔧 程式碼層面的解決方案

我已經在程式碼中實作了以下改善：

### 1. **權限檢查**
```dart
/// 檢查 Firebase 資料庫權限
Future<Map<String, bool>> checkDatabasePermissions() async {
  // 檢查各種權限並返回結果
}
```

### 2. **優雅的錯誤處理**
```dart
/// 刪除配對記錄（含權限錯誤處理）
Future<void> _deleteMatchingRecords(String uid) async {
  try {
    await _database.child('matches/$uid').remove();
  } catch (e) {
    if (e.toString().contains('permission-denied')) {
      debugPrint('權限不足，但繼續其他清理步驟');
      // 不拋出異常，讓其他清理步驟繼續
    } else {
      throw Exception('刪除配對記錄失敗: $e');
    }
  }
}
```

### 3. **用戶友善的錯誤提示**
- 在確認對話框中顯示權限狀態
- 區分可刪除和無法刪除的資料
- 提供清楚的說明和建議

## 🧪 測試步驟

### 1. 檢查當前規則
```bash
# 使用 Firebase CLI
firebase database:get / --project shackhand-autolearn
```

### 2. 測試權限
在應用程式中點擊「完整刪除互助旗和帳號」按鈕，查看權限檢查結果。

### 3. 驗證修改
修改規則後，重新測試刪除功能。

## 📊 權限矩陣

| 路徑 | 讀取 | 寫入 | 刪除 | 說明 |
|------|------|------|------|------|
| `/users/{uid}` | ✅ | ✅ | ✅ | 用戶自己的資料 |
| `/matches/{uid}` | ❓ | ❓ | ❌ | 配對記錄（問題所在） |
| `/matches/{other}/{uid}` | ❌ | ❓ | ❌ | 其他人配對記錄中的引用 |

## 🎯 建議的修改順序

1. **立即修改**: 使用方案 2 的寬鬆規則進行測試
2. **測試完成**: 實作方案 3 的完整規則
3. **生產部署**: 根據實際需求微調規則

## ⚠️ 安全考量

### ✅ 保持安全的原則：
- 用戶只能操作自己的資料
- 需要身份驗證才能存取
- 驗證資料格式和必要欄位

### 🚨 避免的風險：
- 不要使用過於寬鬆的規則
- 不要允許匿名用戶寫入
- 不要忽略資料驗證

## 🔄 回滾計劃

如果修改後出現問題：
1. 立即回到原始規則
2. 檢查錯誤日誌
3. 逐步調整規則
4. 重新測試功能

---

## 📞 需要協助？

如果你需要協助修改 Firebase 規則：
1. 提供當前的安全規則
2. 描述具體的錯誤訊息
3. 說明期望的行為

記住：安全規則的修改需要謹慎，建議在測試環境先驗證！🛡️ 