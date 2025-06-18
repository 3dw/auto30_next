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