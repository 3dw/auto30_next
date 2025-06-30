# 🎯 動態路由教學 - 給高一生的完整指南

## 📚 什麼是動態路由？

### 🏫 用學校的例子來理解

想像你在學校裡：

**靜態路由（固定路徑）：**
- 去「圖書館」 → 永遠是同一個地方
- 去「操場」 → 永遠是同一個地方

**動態路由（變化路徑）：**
- 去「高一X班的教室」 → X可以是1班、2班、3班...
- 去「學號12345同學的座位」 → 12345可以是任何學號

### 🌐 在網頁應用中

**靜態路由：**
```
/home        → 首頁（固定）
/profile     → 個人資料頁（固定）
/map         → 地圖頁（固定）
```

**動態路由：**
```
/user/12345     → 顯示用戶12345的資料
/user/67890     → 顯示用戶67890的資料  
/user/abc123    → 顯示用戶abc123的資料
```

## 🔧 在你的專案中如何實作？

### 1. 設定動態路由

在 `app_router.dart` 中：

```dart
GoRoute(
  path: '/user/:uid',           // ⭐ :uid 是動態參數
  name: 'userDetail',
  builder: (context, state) {
    final uid = state.pathParameters['uid']!;  // 📝 取得動態參數
    return UserDetailScreen(uid: uid);         // 📝 傳給頁面元件
  },
),
```

**解釋：**
- `:uid` 就像一個「變數」，可以放入任何值
- `state.pathParameters['uid']` 用來取得這個變數的值
- 例如訪問 `/user/abc123`，uid 就會是 "abc123"

### 2. QR 碼如何連接到動態路由？

#### 🎯 生成 QR 碼

```dart
final user = FirebaseAuth.instance.currentUser;
final uid = user?.uid ?? '';

// 🔥 QR 碼內容就是動態路由的完整 URL
final qrData = 'https://auto30next.alearn.org.tw/user/$uid';
```

**這樣生成的 QR 碼內容會是：**
- 如果你的 uid 是 "student123"
- QR 碼內容：`https://auto30next.alearn.org.tw/user/student123`

#### 📱 掃描 QR 碼並跳轉

```dart
void _startScanning(BuildContext context) {
  // 假設掃描到：https://auto30next.alearn.org.tw/user/friend456
  final scannedUrl = 'https://auto30next.alearn.org.tw/user/friend456';
  
  // 📝 從 URL 中提取用戶 ID
  final uri = Uri.parse(scannedUrl);
  final pathSegments = uri.pathSegments; // ['user', 'friend456']
  
  if (pathSegments.length >= 2 && pathSegments[0] == 'user') {
    final scannedUserId = pathSegments[1]; // 'friend456'
    
    // 🚀 跳轉到動態路由
    context.push('/user/$scannedUserId');
  }
}
```

## 🎮 完整流程示例

### 情境：小明想分享他的個人資料給小華

1. **小明生成 QR 碼：**
   - 小明的 uid: "ming123"
   - QR 碼內容: `https://auto30next.alearn.org.tw/user/ming123`

2. **小華掃描 QR 碼：**
   - 掃描器讀取到: `https://auto30next.alearn.org.tw/user/ming123`
   - 程式提取出用戶 ID: "ming123"

3. **跳轉到動態路由：**
   - 執行: `context.push('/user/ming123')`
   - Go Router 找到對應路由: `/user/:uid`
   - 將 "ming123" 傳給 `UserDetailScreen`

4. **顯示小明的個人頁面：**
   - `UserDetailScreen` 收到 uid = "ming123"
   - 從 Firebase 載入小明的資料
   - 顯示小明的個人資料頁面

## 💡 為什麼要用動態路由？

### ✅ 優點：

1. **靈活性：** 一個路由模板可以處理無數個用戶
2. **可分享：** 每個用戶都有獨特的 URL 可以分享
3. **SEO 友善：** 搜尋引擎可以索引每個用戶頁面
4. **書籤功能：** 可以收藏特定用戶的頁面

### 🔄 如果不用動態路由會怎樣？

你需要為每個用戶創建一個路由：
```dart
GoRoute(path: '/user_ming123', ...),
GoRoute(path: '/user_hua456', ...),
GoRoute(path: '/user_mei789', ...),
// ... 無限多個路由 😱
```

這樣顯然不實際！

## 🛠️ 其他動態路由的應用

在你的專案中還有這些動態路由：

```dart
// 地圖詳細頁面 - 傳入座標
GoRoute(
  path: '/map_detail/:latlng',
  builder: (context, state) {
    final latlng = state.pathParameters['latlng']!;
    return MapScreen(latlng: latlng);
  },
),

// 互助旗頁面 - 傳入用戶 ID
GoRoute(
  path: '/flag/:uid',
  builder: (context, state) {
    final uid = state.pathParameters['uid']!;
    return UserDetailScreen(uid: uid, showAsFlag: true);
  },
),
```

## 🎯 實際練習

試著理解這些 URL 會發生什麼：

1. `https://auto30next.alearn.org.tw/user/alice123`
   - 顯示用戶 alice123 的個人資料

2. `https://auto30next.alearn.org.tw/flag/bob456`
   - 顯示用戶 bob456 的互助旗

3. `https://auto30next.alearn.org.tw/map_detail/25.0330,121.5654`
   - 顯示座標 25.0330,121.5654 的地圖

## 🚀 總結

動態路由就像是：
- 📋 一個模板：`/user/:uid`
- 🔄 可以填入不同的值：`/user/任何用戶ID`
- 🎯 每個 URL 都指向不同用戶的頁面
- 📱 QR 碼包含完整的 URL，掃描後直接跳轉

這樣你就能讓每個用戶都有自己專屬的可分享連結了！🎉 