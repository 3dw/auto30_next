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


