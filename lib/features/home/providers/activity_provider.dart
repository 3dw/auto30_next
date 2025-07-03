import 'package:flutter/foundation.dart';
import 'package:auto30_next/shared/models/activity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class ActivityProvider with ChangeNotifier {
  final List<Activity> _activities = [];
  bool _isLoading = false;

  List<Activity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;

  // 獲取未讀活動數量
  int get unreadCount => _activities.where((activity) => !activity.isRead).length;

  // 獲取最近的活動（限制數量）
  List<Activity> getRecentActivities([int limit = 10]) {
    final sortedActivities = List<Activity>.from(_activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities.take(limit).toList();
  }

  // 初始化活動數據
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadActivitiesFromStorage();
      await _generateSampleActivities();
    } catch (e) {
      debugPrint('初始化活動數據失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 從本地存儲加載活動
  Future<void> _loadActivitiesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getStringList('activities') ?? [];
      
      _activities.clear();
      for (final jsonString in activitiesJson) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        _activities.add(Activity.fromMap(map));
      }
    } catch (e) {
      debugPrint('加載活動數據失敗: $e');
    }
  }

  // 保存活動到本地存儲
  Future<void> _saveActivitiesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = _activities
          .map((activity) => jsonEncode(activity.toMap()))
          .toList();
      await prefs.setStringList('activities', activitiesJson);
    } catch (e) {
      debugPrint('保存活動數據失敗: $e');
    }
  }

  // 添加新活動
  Future<void> addActivity(Activity activity) async {
    _activities.insert(0, activity);
    notifyListeners();
    await _saveActivitiesToStorage();
  }

  // 標記活動為已讀
  Future<void> markAsRead(String activityId) async {
    final index = _activities.indexWhere((activity) => activity.id == activityId);
    if (index != -1) {
      _activities[index] = _activities[index].copyWith(isRead: true);
      notifyListeners();
      await _saveActivitiesToStorage();
    }
  }

  // 標記所有活動為已讀
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _activities.length; i++) {
      if (!_activities[i].isRead) {
        _activities[i] = _activities[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
    await _saveActivitiesToStorage();
  }

  // 刪除活動
  Future<void> removeActivity(String activityId) async {
    _activities.removeWhere((activity) => activity.id == activityId);
    notifyListeners();
    await _saveActivitiesToStorage();
  }

  // 清空所有活動
  Future<void> clearAllActivities() async {
    _activities.clear();
    notifyListeners();
    await _saveActivitiesToStorage();
  }

  // 添加新朋友活動
  Future<void> addNewFriendActivity({
    required String userName,
    required String userId,
    String? description,
  }) async {
    final activity = ActivityFactory.createNewFriendActivity(
      userName: userName,
      userId: userId,
      description: description,
    );
    await addActivity(activity);
  }

  // 添加附近學習聚會活動
  Future<void> addNearbyEventActivity({
    required String eventTitle,
    required String distance,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final activity = ActivityFactory.createNearbyEventActivity(
      eventTitle: eventTitle,
      distance: distance,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
    await addActivity(activity);
  }

  // 添加興趣配對成功活動
  Future<void> addMatchSuccessActivity({
    required String userName,
    required String userId,
    required List<String> matchedInterests,
    String? description,
  }) async {
    final activity = ActivityFactory.createMatchSuccessActivity(
      userName: userName,
      userId: userId,
      matchedInterests: matchedInterests,
      description: description,
    );
    await addActivity(activity);
  }

  // 生成示例活動（用於演示）
  Future<void> _generateSampleActivities() async {
    if (_activities.isEmpty) {
      final sampleActivities = [
        ActivityFactory.createNewFriendActivity(
          userName: '小明',
          userId: 'user_001',
          description: '來自台北的軟體工程師',
        ),
        ActivityFactory.createNearbyEventActivity(
          eventTitle: 'Flutter 學習聚會',
          distance: '500公尺',
          latitude: 25.0330,
          longitude: 121.5654,
          description: '一起學習 Flutter 開發技術',
        ),
        ActivityFactory.createMatchSuccessActivity(
          userName: '小華',
          userId: 'user_002',
          matchedInterests: ['程式設計', 'Flutter'],
          description: '你們都對 Flutter 開發有興趣',
        ),
      ];

      // 設定不同的時間
      final now = DateTime.now();
      sampleActivities[0] = sampleActivities[0].copyWith(
        timestamp: now.subtract(const Duration(minutes: 5)),
      );
      sampleActivities[1] = sampleActivities[1].copyWith(
        timestamp: now.subtract(const Duration(hours: 1)),
      );
      sampleActivities[2] = sampleActivities[2].copyWith(
        timestamp: now.subtract(const Duration(hours: 3)),
      );

      for (final activity in sampleActivities) {
        _activities.add(activity);
      }

      await _saveActivitiesToStorage();
    }
  }

  // 模擬新朋友加入
  Future<void> simulateNewFriend() async {
    final names = ['小李', '小王', '小陳', '小林', '小張'];
    final descriptions = ['喜歡讀書', '熱愛運動', '愛好音樂', '程式設計師', '設計師'];
    
    final random = Random();
    final name = names[random.nextInt(names.length)];
    final description = descriptions[random.nextInt(descriptions.length)];
    
    await addNewFriendActivity(
      userName: name,
      userId: 'user_${random.nextInt(1000)}',
      description: description,
    );
  }

  // 模擬附近學習聚會
  Future<void> simulateNearbyEvent() async {
    final events = [
      'React Native 工作坊',
      'UI/UX 設計分享',
      'Python 程式設計',
      'JavaScript 進階課程',
      'Flutter 開發實戰',
    ];
    
    final distances = ['200公尺', '350公尺', '500公尺', '800公尺', '1公里'];
    
    final random = Random();
    final event = events[random.nextInt(events.length)];
    final distance = distances[random.nextInt(distances.length)];
    
    await addNearbyEventActivity(
      eventTitle: event,
      distance: distance,
      latitude: 25.0330 + (random.nextDouble() - 0.5) * 0.01,
      longitude: 121.5654 + (random.nextDouble() - 0.5) * 0.01,
      description: '一起學習交流的好機會',
    );
  }

  // 模擬興趣配對成功
  Future<void> simulateMatchSuccess() async {
    final names = ['小美', '小強', '小芳', '小偉', '小雯'];
    final interests = [
      ['程式設計', 'Flutter'],
      ['音樂', '吉他'],
      ['運動', '游泳'],
      ['閱讀', '文學'],
      ['旅行', '攝影'],
    ];
    
    final random = Random();
    final name = names[random.nextInt(names.length)];
    final interest = interests[random.nextInt(interests.length)];
    
    await addMatchSuccessActivity(
      userName: name,
      userId: 'user_${random.nextInt(1000)}',
      matchedInterests: interest,
      description: '你們有共同的興趣愛好',
    );
  }
} 