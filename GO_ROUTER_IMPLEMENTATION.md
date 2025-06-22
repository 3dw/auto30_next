# Go Router 動態路由實現總結

## 已實現的功能

### 1. 路由配置 (`lib/core/config/app_router.dart`)
- ✅ 設置 go_router 作為主要路由系統
- ✅ 整合 AuthProvider 進行身份驗證導向
- ✅ 自動重導向邏輯（未登入→登入頁面，已登入→首頁）

### 2. 主要頁面路由
- ✅ `/` - 首頁 (HomeScreen)
- ✅ `/login` - 登入頁面
- ✅ `/map` - 地圖頁面
- ✅ `/match` - 配對頁面
- ✅ `/social` - 社群頁面
- ✅ `/qr` - QR碼頁面
- ✅ `/learning` - 學習中心頁面
- ✅ `/profile` - 個人資料頁面

### 3. 動態路由
- ✅ `/user/:uid` - 用戶詳細頁面
- ✅ `/flag/:uid` - 互助旗頁面（用戶詳細頁面的變體）

### 4. 用戶詳細頁面 (`lib/features/profile/user_detail_screen.dart`)
- ✅ 處理 Firebase 資料載入狀態
- ✅ 顯示載入中提示
- ✅ 錯誤處理和重試功能
- ✅ 完整的用戶資訊顯示
- ✅ 支援互助旗模式
- ✅ 動作按鈕（傳送訊息、在地圖上查看）

### 5. 現有頁面的路由更新
- ✅ HomeScreen - 所有導航按鈕改用 `context.go()`
- ✅ MapScreen - 「查看完整資料」改用動態路由 `/user/:uid`
- ✅ MatchScreen - 返回按鈕改用 `context.pop()`

### 6. 主應用程式更新 (`lib/main.dart`)
- ✅ 替換 MaterialApp 為 MaterialApp.router
- ✅ 整合 go_router 配置

## 路由使用方式

### 基本導航
```dart
// 導航到特定頁面
context.go('/map');
context.go('/match');

// 返回上一頁
context.pop();

// 導航到用戶詳細頁面
context.go('/user/userId123');

// 導航到互助旗頁面
context.go('/flag/userId123');
```

### 動態路由參數獲取
```dart
// 在路由定義中
GoRoute(
  path: '/user/:uid',
  builder: (context, state) {
    final uid = state.pathParameters['uid']!;
    return UserDetailScreen(uid: uid);
  },
)
```

## Firebase 資料載入處理

UserDetailScreen 具備完整的載入狀態管理：

1. **載入中狀態** - 顯示 CircularProgressIndicator
2. **錯誤狀態** - 顯示錯誤訊息和重試按鈕
3. **空資料狀態** - 顯示「找不到用戶資料」
4. **成功狀態** - 顯示完整用戶資訊

## 網址結構

- `https://yourapp.com/` - 首頁
- `https://yourapp.com/map` - 地圖
- `https://yourapp.com/user/ABC123` - 用戶 ABC123 的詳細頁面
- `https://yourapp.com/flag/ABC123` - 用戶 ABC123 的互助旗頁面

## 測試方式

1. 啟動應用程式：`fvm flutter run -d chrome --web-port=8000`
2. 在瀏覽器中訪問不同路由
3. 測試地圖頁面的「查看完整資料」按鈕
4. 驗證動態路由和載入狀態

## 注意事項

- Firebase 資料在載入期間會顯示適當的載入狀態
- 錯誤處理包含重試機制
- 所有導航都使用 go_router 的 API
- 路由配置集中管理，便於維護 