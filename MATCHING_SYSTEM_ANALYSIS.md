# 配對系統程式碼分析

## 📋 **概述**

本專案實現了一個智能配對系統，提供類似 Tinder 的卡片式配對介面，支援多種配對模式和詳細的用戶資訊展示。

## 🏗️ **檔案結構**

### 主要檔案
- `lib/features/match/match_screen.dart` - 配對主頁面
- `lib/core/config/app_router.dart` - 路由配置
- `lib/features/home/presentation/screens/home_screen.dart` - 首頁導航
- `lib/features/social/presentation/screens/social_main_screen.dart` - 底部導航

## 🎯 **核心功能**

### 1. **智能配對系統**
提供 4 種不同的配對模式：
```dart
final List<String> filters = ['興趣配對', '位置配對', '技能配對', '隨機配對'];
```

### 2. **卡片式配對介面**
- 滑動動畫效果
- 配對成功動畫
- 用戶資訊卡片展示

### 3. **詳細用戶資訊**
- 基本資料（姓名、年齡、距離）
- 配對分數
- 興趣愛好標籤
- 專長技能標籤
- 個人介紹

## 📊 **資料結構**

### 用戶資料模型
```dart
final List<Map<String, dynamic>> users = [
  {
    'name': '小安',
    'age': 15,
    'distance': 1.3,
    'match': 95,
    'intro': '我是一直熱愛學習的人，希望能找到一起進步的夥伴！',
    'interests': ['音樂', '藝術', '文學'],
    'skills': ['英文對話', '日文基礎'],
  },
  {
    'name': '小杰',
    'age': 18,
    'distance': 2.6,
    'match': 85,
    'intro': '我是一個熱愛學習的人，希望能找到一起進步的夥伴！',
    'interests': ['程式設計', '數學', '物理'],
    'skills': ['Flutter開發', 'Python程式設計'],
  },
];
```

## 🔧 **核心程式碼實作**

### 1. **配對成功邏輯**
```dart
void _matchSuccess() {
  final user = users[currentIndex];
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('你對${user['name']}產生興趣'),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1200),
    ),
  );
  setState(() {
    matched = true;
  });
  Future.delayed(const Duration(seconds: 1), _nextUser);
}
```

### 2. **用戶切換機制**
```dart
void _nextUser() {
  setState(() {
    matched = false;
    if (users.length > 1) {
      currentIndex = (currentIndex + 1) % users.length;
    }
  });
  _animationController.reset();
  _animationController.forward();
}
```

## 🎨 **UI 組件詳解**

### 1. **配對卡片** (`_MatchingCard`)
**功能：**
- 顯示用戶基本資訊
- 配對分數展示
- 興趣和技能標籤
- 響應式設計（桌面/手機）

### 2. **詳細資訊彈窗** (`_CandidateDetailSheet`)
**功能：**
- 完整的用戶資料展示
- 配對分析資訊
- 互動按鈕（發送訊息、表示興趣）

### 3. **操作按鈕區域**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    FloatingActionButton(
      heroTag: "reject",
      onPressed: _nextUser,
      backgroundColor: Colors.deepOrange,
      child: const Icon(Icons.close, color: Colors.white),
    ),
    FloatingActionButton(
      heroTag: "info",
      onPressed: () => _showUserInfoBottomSheet(context),
      backgroundColor: Colors.orange.shade600,
      child: const Icon(Icons.info, color: Colors.white),
    ),
    FloatingActionButton(
      heroTag: "accept",
      onPressed: _matchSuccess,
      backgroundColor: Colors.orange,
      child: const Icon(Icons.favorite, color: Colors.white),
    ),
  ],
)
```

## 🛣️ **路由整合**

### 1. **路由配置**
```dart
// app_router.dart
GoRoute(
  path: '/match',
  name: 'match',
  builder: (context, state) => const MatchScreen(),
),
```

### 2. **首頁導航**
```dart
// home_screen.dart
case '隨機配對':
  context.push('/match');
  break;
```

## 📱 **響應式設計**

### 桌面版適配
```dart
final screenSize = MediaQuery.of(context).size;
final isDesktop = screenSize.width > 600;

// 根據螢幕大小調整佈局
padding: EdgeInsets.all(isDesktop ? 20 : 16),
maxWidth: isDesktop ? 500 : double.infinity,
fontSize: isDesktop ? 28 : 24,
```

## 🔄 **狀態管理**

### 主要狀態變數
```dart
int filterIndex = 0;           // 當前選中的配對類型
int currentIndex = 0;          // 當前顯示的用戶索引
bool matched = false;          // 是否已配對成功
bool isLoading = false;        // 載入狀態
```

## 🚀 **未來改進建議**

### 1. **整合 Firebase 資料**
```dart
Future<List<Map<String, dynamic>>> _fetchUsersFromFirebase() async {
  final ref = FirebaseDatabase.instance.ref('users');
  final snapshot = await ref.get();
  
  if (snapshot.exists && snapshot.value != null) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final List<Map<String, dynamic>> users = [];
    
    data.forEach((key, value) {
      if (value is Map) {
        final userData = value as Map<String, dynamic>;
        // 根據配對類型篩選用戶
        if (_shouldIncludeUser(userData)) {
          users.add(_formatUserData(key, userData));
        }
      }
    });
    
    return users;
  }
  return [];
}
```

### 2. **智能配對演算法**
```dart
double _calculateMatchScore(Map<String, dynamic> currentUser, Map<String, dynamic> candidate) {
  double score = 0.0;
  
  // 興趣匹配度 (40%)
  score += _calculateInterestMatch(currentUser['learner_habit'], candidate['learner_habit']) * 0.4;
  
  // 地理位置距離 (30%)
  score += _calculateDistanceScore(currentUser['latlngColumn'], candidate['latlngColumn']) * 0.3;
  
  // 技能互補性 (20%)
  score += _calculateSkillComplement(currentUser['share'], candidate['ask']) * 0.2;
  
  // 年齡相容性 (10%)
  score += _calculateAgeCompatibility(currentUser['learner_birth'], candidate['learner_birth']) * 0.1;
  
  return score;
}
```

## 📊 **功能完成度評估**

| 功能項目 | 完成度 | 狀態 |
|---------|--------|------|
| UI 介面設計 | 100% | ✅ 完成 |
| 動畫效果 | 100% | ✅ 完成 |
| 響應式設計 | 100% | ✅ 完成 |
| 路由整合 | 100% | ✅ 完成 |
| 假資料展示 | 100% | ✅ 完成 |
| Firebase 整合 | 0% | ❌ 未實作 |
| 智能配對演算法 | 0% | ❌ 未實作 |
| 配對記錄管理 | 0% | ❌ 未實作 |

## 🎯 **總結**

目前的配對系統提供了完整的 UI 架構和用戶體驗，包括：
- ✅ 美觀的卡片式配對介面
- ✅ 流暢的動畫效果
- ✅ 詳細的用戶資訊展示
- ✅ 多種配對模式選擇
- ✅ 響應式設計支援

**下一步重點：**
1. 整合 Firebase 真實資料
2. 實作智能配對演算法
3. 添加配對記錄和通知功能
4. 優化配對效率和用戶體驗

這個配對系統為自學社交平台提供了強大的用戶連接功能，為後續的功能擴展奠定了堅實的基礎。
