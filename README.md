# Auto30 Next

A next-generation version of auto20-next with enhanced features inspired by frankly.

## Features

- Modern Flutter-based UI with Material Design 3
- Firebase Authentication (Email/Password and Google Sign-in)
- Responsive design for multiple platforms (Android, iOS, Web)
- State management using Provider
- Theme support (Light/Dark mode)
- Navigation using bottom navigation bar
- Clean architecture with feature-based organization

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Firebase project setup
- Android Studio / Xcode (for mobile development)
- VS Code (recommended for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/3dw/auto30_next.git
cd auto30_next
```

2. Install dependencies:
```bash
flutter pub get
```

or (if using fvm 來切換Flutter版本)

```
fvm flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

or (if using fvm 來切換Flutter版本，且要能google登入)

```
fvm flutter run -d chrome --web-port=8000
```

## Project Structure

```
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   └── settings/
└── shared/
    ├── widgets/
    ├── models/
    └── services/
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [auto20-next](https://github.com/3dw/auto20-next) - The original project
- [frankly](https://github.com/berkmancenter/frankly) - Inspiration for new features
- Flutter team for the amazing framework
- Firebase team for the backend services

## Firebase 配置說明

本專案使用 Firebase 作為後端服務，請依照以下步驟配置 Firebase：

1. 前往 [Firebase Console](https://console.firebase.google.com/) 建立新專案或使用現有專案。
2. 在專案設定中，選擇「新增應用」，並依照指示註冊 Web、Android 或 iOS 應用。
3. 下載 Firebase 設定檔：
   - 對於 Android，下載 `google-services.json` 並放置於 `android/app/` 目錄中。
   - 對於 iOS，下載 `GoogleService-Info.plist` 並放置於 `ios/Runner/` 目錄中。
4. 使用 Firebase CLI 或手動方式生成 `firebase_options.dart` 檔案，並將其放置於 `lib/core/config/` 目錄下。
5. 請注意：`firebase_options.dart`、`google-services.json` 和 `GoogleService-Info.plist` 包含敏感資訊，已加入 .gitignore，請勿上傳至版本控制系統。可參考 `firebase_options.example.dart`、`google-services.example.json` 和 `GoogleService-Info.example.plist` 了解配置結構。


## 本專案的整體架構和設定：


1. **目前的部署設定**：
   - 是的，目前的 GitHub Actions workflow（deploy.yml）只針對 web 部署進行設定
   - 主要用於將 Flutter web 應用部署到 GitHub Pages

2. **專案架構分析**：
   - 專案已經包含完整的 Flutter 跨平台結構，包括：
     - `android/` - Android 平台相關配置
     - `ios/` - iOS 平台相關配置
     - `web/` - Web 平台相關配置
     - `lib/` - 主要的 Dart/Flutter 代碼
     - `test/` - 測試目錄

3. **依賴配置（pubspec.yaml）分析**：
   專案的依賴配置非常完整，已經包含了跨平台開發所需的重要套件：
   - Firebase 相關：`firebase_core`, `firebase_auth`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`
   - 本地存儲：`sqflite`, `shared_preferences`, `hive`
   - 網路請求：`dio`, `http`
   - 狀態管理：`provider`, `flutter_bloc`
   - 平台特定功能：`device_info_plus`, `package_info_plus`
   - 推送通知：`flutter_local_notifications`

4. **未來擴展可行性**：
   是的，目前的專案架構完全支援未來擴展到 iOS 和 Android 平台：
   - 基礎架構已經準備就緒
   - 依賴配置包含了跨平台所需的主要套件
   - 專案結構符合 Flutter 跨平台開發標準

5. **建議的後續步驟**：
   如果要擴展到 iOS 和 Android，你需要：

   a) iOS 平台：
   - 設定 iOS 開發證書和配置文件
   - 更新 `ios/Runner/Info.plist` 的必要權限
   - 配置 Firebase iOS 設定文件

   b) Android 平台：
   - 設定 Android 簽名金鑰
   - 更新 `android/app/build.gradle` 的必要配置
   - 配置 Firebase Android 設定文件

   c) CI/CD 擴展：
   - 為 iOS 和 Android 建立新的 workflow 文件
   - 設定相應的簽名和發布流程
   - 配置 App Store Connect 和 Google Play Console 的自動化發布

總結來說，你的專案架構非常健全，完全支援未來向 iOS 和 Android 平台擴展。目前的 web 部署只是第一步，但專案的基礎設施和依賴配置已經為跨平台開發做好了準備。當你準備好擴展到移動平台時，主要的工作將集中在平台特定的配置和 CI/CD 流程的建立上。

## 功能連接關係說明

### 📍 **首頁「附近的人」功能**

#### 🔗 **連接路徑：**
1. **首頁按鈕** → `lib/features/home/presentation/screens/home_screen.dart`
2. **路由導航** → `lib/core/config/app_router.dart`
3. **目標頁面** → `lib/features/map/map_screen.dart`

#### 📋 **詳細流程：**

**1. 首頁按鈕定義** (`home_screen.dart` 第 138-221 行)：
```dart
class _QuickFeatureCard extends StatelessWidget {
  // ...
  void _onTap() {
    switch (title) {
      case '附近的人':
        context.push('/map');  // 導航到地圖頁面
        break;
      // ...
    }
  }
}
```

**2. 路由設定** (`app_router.dart` 第 50-55 行)：
```dart
GoRoute(
  path: '/map',
  name: 'map',
  builder: (context, state) => const MapScreen(),
),
```

**3. 地圖頁面** (`map_screen.dart`)：
- 顯示所有用戶的位置標記
- 從 Firebase 載入用戶資料
- 支援點擊用戶標記查看詳細資訊

---

### 🗺️ **個人資料「在地圖上設定位置」功能**

#### 🔗 **連接路徑：**
1. **個人資料頁面** → `lib/features/profile/profile_screen.dart`
2. **位置選擇器** → `lib/features/profile/location_picker_screen.dart`
3. **返回個人資料** → 更新位置座標

#### 📋 **詳細流程：**

**1. 個人資料頁面按鈕** (`profile_screen.dart` 第 280-295 行)：
```dart
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _latlng != null
              ? LatLng(_latlng!['lat']!, _latlng!['lng']!)
              : null
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _latlng = {
          'lat': result.latitude,
          'lng': result.longitude,
        };
      });
    }
  },
  child: const Text('在地圖上設定位置'),
)
```

**2. 位置選擇器頁面** (`location_picker_screen.dart`)：
- 提供互動式地圖讓用戶選擇位置
- 顯示當前選擇的座標
- 支援拖曳地圖來調整位置

**3. 資料儲存** (`profile_screen.dart` 第 175-185 行)：
```dart
'latlngColumn': _latlng != null ? { 
  'lat': _latlng!['lat'], 
  'lng': _latlng!['lng'] 
} : null,
```

---

### 📊 **功能對照表**

| 功能 | 起始檔案 | 目標檔案 | 路由路徑 |
|------|----------|----------|----------|
| **附近的人** | `home_screen.dart` | `map_screen.dart` | `/map` |
| **在地圖上設定位置** | `profile_screen.dart` | `location_picker_screen.dart` | 直接導航 |

### 💡 **功能說明**

這兩個功能都與地圖相關，但用途不同：
- **附近的人**：查看其他用戶的位置，支援點擊查看用戶詳細資料
- **在地圖上設定位置**：設定自己的位置，用於個人資料中的地理位置資訊

### 🔧 **技術實現**

- 使用 `flutter_map` 套件實現地圖功能
- 整合 `flutter_map_cancellable_tile_provider` 優化網頁版性能
- 使用 `geolocator` 套件處理位置權限和獲取當前位置
- 透過 Firebase Realtime Database 儲存和讀取用戶位置資料

# auto30_next 專案說明

## 主要功能與檔案結構

### 1. 地圖與配對功能
- 地圖頁面：`lib/features/map/map_screen.dart`
- 「附近的人」：地圖頁面會顯示附近用戶，需取得位置權限。
- 個人資料 >> 在地圖上設定位置：`lib/features/profile/location_picker_screen.dart`
- 路由設定：`lib/core/config/app_router.dart`
- 權限設定與地圖 tile provider 已優化，效能提升。

### 2. 配對系統
- 配對主頁：`lib/features/match/match_screen.dart`
- 配對紀錄頁：`lib/features/match/match_history_screen.dart`
- 配對邏輯、排序、UI 皆參考 Tinder 卡片式滑動，支援興趣、位置、技能、隨機配對。
- Like/配對紀錄寫入 Firebase，紀錄可查詢與刪除。

### 3. 個人資料欄位
- 個人資料頁：`lib/features/profile/profile_screen.dart`
- 詳細資料頁：`lib/features/profile/user_detail_screen.dart`
- 補齊欄位：身份、自學型態、孩子出生年（只需年份）、可用時段等。
- 地理座標 latlngColumn 儲存格式為字串 "lat,lng"。

### 4. QR Code 功能
- 我的ＱＲ碼：`lib/features/qr/presentation/screens/my_qr_screen.dart`
- 掃描ＱＲ碼：`lib/features/qr/presentation/screens/scan_qr_screen.dart`
- 入口與路由：`lib/core/config/app_router.dart`
- 掃描後自動跳轉至個人資料頁。

### 5. Firebase 權限與資料結構
- 請參考 `README_DEPLOY.md` 及下方 MATCHING_SYSTEM_ANALYSIS.md。
- matches 路徑需開放正確讀寫權限。

### 6. 其他
- Dart 語法錯誤、import 問題、UI 顯示問題皆已多次修正。
- 所有功能均以中文說明，並根據需求直接修改程式碼。


