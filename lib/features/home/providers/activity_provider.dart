import 'package:flutter/foundation.dart';
import 'package:auto30_next/shared/models/activity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';

class ActivityProvider with ChangeNotifier {
  final List<Activity> _activities = [];
  bool _isLoading = false;
  int _newFriendFilterDays = 2; // 新朋友活動過濾天數，改為2天

  List<Activity> get activities {
    // 過濾活動：新朋友活動只顯示指定天數內註冊且有升起互助旗的用戶
    final filteredActivities = _activities.where((activity) {
      if (activity.type == ActivityType.newFriend) {
        if (activity.registrationDate != null) {
          final filterDate = DateTime.now().subtract(Duration(days: _newFriendFilterDays));
          return activity.registrationDate!.isAfter(filterDate) && activity.hasFlag;
        }
        return false; // 如果沒有註冊日期，不顯示
      }
      return true; // 其他類型的活動正常顯示
    }).toList();
    
    return List.unmodifiable(filteredActivities);
  }
  bool get isLoading => _isLoading;
  int get newFriendFilterDays => _newFriendFilterDays;

  // 獲取未讀活動數量
  int get unreadCount => activities.where((activity) => !activity.isRead).length;

  // 設置新朋友活動過濾天數
  void setNewFriendFilterDays(int days) {
    if (days != _newFriendFilterDays) {
      _newFriendFilterDays = days;
      notifyListeners();
    }
  }

  // 檢查是否有符合條件的新朋友（指定天數內註冊且有升起互助旗）
  bool hasQualifiedNewFriends() {
    return _activities.any((activity) {
      if (activity.type == ActivityType.newFriend) {
        if (activity.registrationDate != null) {
          final filterDate = DateTime.now().subtract(Duration(days: _newFriendFilterDays));
          return activity.registrationDate!.isAfter(filterDate) && activity.hasFlag;
        }
      }
      return false;
    });
  }

  // 獲取符合條件的新朋友數量
  int getQualifiedNewFriendsCount() {
    return _activities.where((activity) {
      if (activity.type == ActivityType.newFriend) {
        if (activity.registrationDate != null) {
          final filterDate = DateTime.now().subtract(Duration(days: _newFriendFilterDays));
          return activity.registrationDate!.isAfter(filterDate) && activity.hasFlag;
        }
      }
      return false;
    }).length;
  }

  // 獲取最近的活動（限制數量）
  List<Activity> getRecentActivities([int limit = 10]) {
    final sortedActivities = List<Activity>.from(activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities.take(limit).toList();
  }

  // 初始化活動數據
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadActivitiesFromStorage();
      await _loadRealUsersFromFirebase(); // 新增：從 Firebase 讀取真實用戶
      await _generateSampleActivities();
    } catch (e) {
      debugPrint('初始化活動數據失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 從 Firebase 讀取真實用戶並創建新朋友活動
  Future<void> _loadRealUsersFromFirebase() async {
    try {
      debugPrint('開始從 Firebase 讀取真實用戶...');
      
      final ref = FirebaseDatabase.instance.ref('users');
      final snapshot = await ref.get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final now = DateTime.now();
        final filterDate = now.subtract(Duration(days: _newFriendFilterDays));
        
        debugPrint('找到 ${data.length} 個用戶，過濾條件：${_newFriendFilterDays}天內註冊');
        
        int qualifiedCount = 0;
        
        for (final entry in data.entries) {
          final userId = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);
          
          // 特別檢查目標用戶
          if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
            debugPrint('=== 檢查目標用戶 $userId ===');
            debugPrint('用戶資料: $userData');
          }
          
          // 檢查用戶是否有基本資料
          final userName = userData['name'] as String?;
          if (userName == null || userName.isEmpty) {
            debugPrint('跳過用戶 $userId：缺少用戶名');
            continue;
          }
          
          // 檢查註冊時間（使用 lastUpdate 或 creationTime）
          DateTime? registrationDate;
          if (userData['lastUpdate'] != null) {
            registrationDate = DateTime.fromMillisecondsSinceEpoch(userData['lastUpdate']);
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶最後更新時間: $registrationDate');
            }
          } else if (userData['creationTime'] != null) {
            registrationDate = DateTime.fromMillisecondsSinceEpoch(userData['creationTime']);
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶創建時間: $registrationDate');
            }
          }
          
          if (registrationDate == null) {
            debugPrint('跳過用戶 $userId：無法確定註冊時間');
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶無法確定註冊時間');
            }
            continue;
          }
          
          // 檢查是否在指定天數內註冊
          if (!registrationDate.isAfter(filterDate)) {
            debugPrint('跳過用戶 $userId：註冊時間 ${registrationDate.toString()} 超過 ${_newFriendFilterDays} 天');
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶註冊時間超過 ${_newFriendFilterDays} 天');
            }
            continue;
          }
          
          // 檢查互助旗狀態
          final flagDown = userData['flag_down'] as bool? ?? false;
          final hasFlag = !flagDown; // 互助旗升起 = 未降下
          
          if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
            debugPrint('目標用戶互助旗狀態: flag_down=$flagDown, hasFlag=$hasFlag');
          }
          
          if (!hasFlag) {
            debugPrint('跳過用戶 $userId：互助旗已降下');
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶互助旗已降下');
            }
            continue;
          }
          
          // 檢查是否已經有這個用戶的活動
          final existingActivity = _activities.any((activity) => 
            activity.type == ActivityType.newFriend && 
            activity.userId == userId
          );
          
          if (existingActivity) {
            debugPrint('跳過用戶 $userId：已存在活動記錄');
            if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
              debugPrint('目標用戶已存在活動記錄');
            }
            continue;
          }
          
          // 創建新朋友活動
          final description = userData['address'] as String? ?? '來自未知地區';
          
          await addNewFriendActivity(
            userName: userName,
            userId: userId,
            description: description,
            registrationDate: registrationDate,
            hasFlag: hasFlag,
          );
          
          qualifiedCount++;
          debugPrint('✅ 為用戶 $userName ($userId) 創建新朋友活動');
          
          if (userId == 'eRZCNMNnyUO7nRAhidr0fd1K1ch1') {
            debugPrint('✅ 成功為目標用戶創建新朋友活動！');
          }
        }
        
        debugPrint('成功為 $qualifiedCount 個符合條件的用戶創建新朋友活動');
      } else {
        debugPrint('Firebase 中沒有用戶資料');
      }
    } catch (e) {
      debugPrint('從 Firebase 讀取用戶時發生錯誤: $e');
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
    DateTime? registrationDate,
    bool hasFlag = false,
  }) async {
    final activity = ActivityFactory.createNewFriendActivity(
      userName: userName,
      userId: userId,
      description: description,
      registrationDate: registrationDate,
      hasFlag: hasFlag,
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
      final now = DateTime.now();
      
      // 只生成指定天數內且有升起互助旗的新朋友活動
      final sampleActivities = [
        ActivityFactory.createNewFriendActivity(
          userName: '小明',
          userId: 'user_001',
          description: '來自台北的軟體工程師',
          registrationDate: now.subtract(const Duration(days: 5)),
          hasFlag: true,
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

  // 模擬新朋友加入（只生成指定天數內註冊且有升起互助旗的用戶）
  Future<void> simulateNewFriend() async {
    final names = ['小李', '小王', '小陳', '小林', '小張'];
    final descriptions = ['喜歡讀書', '熱愛運動', '愛好音樂', '程式設計師', '設計師'];
    
    final random = Random();
    final name = names[random.nextInt(names.length)];
    final description = descriptions[random.nextInt(descriptions.length)];
    
    // 隨機生成指定天數內的註冊日期
    final now = DateTime.now();
    final filterDate = now.subtract(Duration(days: _newFriendFilterDays));
    final daysSinceRegistration = random.nextInt(_newFriendFilterDays);
    final registrationDate = filterDate.add(Duration(days: daysSinceRegistration));
    
    await addNewFriendActivity(
      userName: name,
      userId: 'user_${random.nextInt(1000)}',
      description: description,
      registrationDate: registrationDate,
      hasFlag: true, // 新朋友必須有升起互助旗
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