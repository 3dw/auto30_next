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