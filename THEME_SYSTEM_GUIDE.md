# 🎨 Auto30 Next 主題系統使用指南

## 📍 主題模式設定位置

### 🎯 在哪裡設定白天/黑夜模式？

你可以在以下地方找到主題設定：

1. **首頁右上角** → 點擊頭像圖示 → 選擇「設定」
2. **直接訪問設定頁面**：`/settings`

### 🛠️ 主題系統架構

```
lib/
├── main.dart                              # 主應用程式 - 整合 ThemeProvider
├── core/
│   ├── providers/
│   │   └── theme_provider.dart           # 主題狀態管理
│   └── theme/
│       └── app_theme.dart               # 主題樣式定義
└── features/
    ├── home/
    │   └── home_screen.dart             # 首頁 - 設定入口
    └── settings/
        └── settings_screen.dart         # 設定頁面 - 主題控制
```

## 🎨 主題模式選項

### 1. 🌞 白天模式 (Light Mode)
- **特色**：明亮清新的橘色主題
- **適用**：白天使用、明亮環境
- **色彩**：橘色 (#FF9800) + 白色背景

### 2. 🌙 黑夜模式 (Dark Mode)
- **特色**：深色護眼主題
- **適用**：夜晚使用、暗光環境
- **色彩**：橘色 (#FF9800) + 深色背景

### 3. 🔄 跟隨系統 (System Mode)
- **特色**：自動跟隨裝置系統設定
- **適用**：希望與系統保持一致
- **行為**：系統是白天就顯示白天，系統是黑夜就顯示黑夜

## 🚀 如何使用主題系統

### 📱 在設定頁面切換主題

1. **進入設定頁面**
   ```
   首頁 → 右上角頭像 → 設定
   ```

2. **外觀設定區塊**
   - 看到目前的主題模式
   - 三個選項按鈕：跟隨系統、白天模式、黑夜模式
   - 點擊任一選項即可切換

3. **快速切換**
   - 點擊右側的刷新按鈕 🔄
   - 會依序切換：系統 → 白天 → 黑夜 → 系統

### 💾 設定會自動儲存

- 你的主題偏好會自動儲存到裝置
- 下次開啟應用程式時會記住你的選擇
- 使用 `SharedPreferences` 進行本地儲存

## 🔧 技術實作細節

### ThemeProvider 功能

```dart
class ThemeProvider extends ChangeNotifier {
  // 主要功能
  ThemeMode get themeMode           // 取得當前主題模式
  bool get isDarkMode              // 是否為黑夜模式
  bool get isLightMode             // 是否為白天模式
  bool get isSystemMode            // 是否為系統模式
  
  // 切換方法
  setLightMode()                   // 設定為白天模式
  setDarkMode()                    // 設定為黑夜模式
  setSystemMode()                  // 設定為跟隨系統
  toggleThemeMode()                // 循環切換模式
}
```

### 在其他頁面使用主題

```dart
// 監聽主題變化
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Text(
      '目前主題：${themeProvider.themeModeText}',
      style: TextStyle(
        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
      ),
    );
  },
)

// 直接使用主題
final themeProvider = context.read<ThemeProvider>();
if (themeProvider.isDarkMode) {
  // 黑夜模式的特殊處理
}
```

## 🎯 自訂主題顏色

### 修改主題色彩

如果你想要修改主題顏色，可以編輯 `lib/core/theme/app_theme.dart`：

```dart
class AppTheme {
  // 🎨 主要顏色設定
  static const Color primaryColor = Color(0xFFFF9800);    // 主色：橘色
  static const Color secondaryColor = Color(0xFFF57C00);  // 次要色：深橘色
  static const Color accentColor = Color(0xFFFFE0B2);     // 強調色：淺橘色
  
  // 🚨 狀態顏色
  static const Color errorColor = Color(0xFFD32F2F);      // 錯誤：紅色
  static const Color successColor = Color(0xFF388E3C);    // 成功：綠色
  static const Color warningColor = Color(0xFFF57C00);    // 警告：橘色
}
```

### 添加新的主題變體

你可以在 `AppTheme` 類別中添加更多主題：

```dart
static ThemeData get blueTheme {
  return ThemeData(
    // 藍色主題設定
    primaryColor: Colors.blue,
    // ... 其他設定
  );
}
```

## 📱 使用者體驗特色

### 🔄 平滑切換動畫
- 主題切換時有平滑的過渡動畫
- Flutter 自動處理顏色漸變效果

### 💾 持久化儲存
- 使用者的主題偏好會永久儲存
- 重新開啟應用程式時保持設定

### 🎨 視覺回饋
- 設定頁面會即時顯示當前選擇的主題
- 選中的主題選項有明顯的視覺標示

### 📱 響應式設計
- 主題系統在所有螢幕尺寸上都能正常工作
- 桌面版和手機版都有良好的體驗

## 🚀 未來擴展可能

### 🎨 更多主題選項
- 可以添加更多預設主題（如藍色、綠色主題）
- 支援自訂主題顏色

### ⏰ 定時切換
- 可以添加依時間自動切換主題的功能
- 例如：白天自動切換到白天模式，晚上切換到黑夜模式

### 🎯 個人化設定
- 允許使用者自訂主色調
- 支援更細緻的外觀調整

## 🎉 總結

現在你的 Auto30 Next 應用程式擁有完整的主題系統：

✅ **三種主題模式**：白天、黑夜、跟隨系統  
✅ **簡單易用**：在設定頁面一鍵切換  
✅ **自動儲存**：設定會永久保存  
✅ **美觀設計**：橘色主題配色協調  
✅ **響應式**：適配所有裝置尺寸  

享受你的個人化主題體驗吧！🎨 