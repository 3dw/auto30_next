import 'package:flutter/material.dart';

enum ActivityType {
  newFriend,
  nearbyEvent,
  matchSuccess,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final String? description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final double? latitude;
  final double? longitude;
  final String? distance;
  final List<String>? matchedInterests;
  final bool isRead;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.description,
    required this.timestamp,
    this.userId,
    this.userName,
    this.latitude,
    this.longitude,
    this.distance,
    this.matchedInterests,
    this.isRead = false,
  });

  // 獲取活動圖示
  IconData get icon {
    switch (type) {
      case ActivityType.newFriend:
        return Icons.person_add;
      case ActivityType.nearbyEvent:
        return Icons.event;
      case ActivityType.matchSuccess:
        return Icons.favorite;
    }
  }

  // 獲取活動顏色
  Color get color {
    switch (type) {
      case ActivityType.newFriend:
        return Colors.blue;
      case ActivityType.nearbyEvent:
        return Colors.green;
      case ActivityType.matchSuccess:
        return Colors.red;
    }
  }

  // 獲取時間格式化字符串
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${difference.inDays ~/ 7}週前';
    }
  }

  // 複製並更新活動
  Activity copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? subtitle,
    String? description,
    DateTime? timestamp,
    String? userId,
    String? userName,
    double? latitude,
    double? longitude,
    String? distance,
    List<String>? matchedInterests,
    bool? isRead,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      matchedInterests: matchedInterests ?? this.matchedInterests,
      isRead: isRead ?? this.isRead,
    );
  }

  // 轉換為 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'matchedInterests': matchedInterests,
      'isRead': isRead,
    };
  }

  // 從 Map 創建
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      type: ActivityType.values[map['type']],
      title: map['title'],
      subtitle: map['subtitle'],
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      userId: map['userId'],
      userName: map['userName'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      distance: map['distance'],
      matchedInterests: map['matchedInterests'] != null
          ? List<String>.from(map['matchedInterests'])
          : null,
      isRead: map['isRead'] ?? false,
    );
  }
}

// 活動工廠類，用於創建不同類型的活動
class ActivityFactory {
  static Activity createNewFriendActivity({
    required String userName,
    required String userId,
    String? description,
  }) {
    return Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.newFriend,
      title: '新朋友加入',
      subtitle: '$userName剛剛註冊了平台',
      description: description,
      timestamp: DateTime.now(),
      userId: userId,
      userName: userName,
    );
  }

  static Activity createNearbyEventActivity({
    required String eventTitle,
    required String distance,
    required double latitude,
    required double longitude,
    String? description,
  }) {
    return Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.nearbyEvent,
      title: '附近的學習聚會',
      subtitle: '距離你 $distance',
      description: description ?? eventTitle,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      distance: distance,
    );
  }

  static Activity createMatchSuccessActivity({
    required String userName,
    required String userId,
    required List<String> matchedInterests,
    String? description,
  }) {
    final interestText = matchedInterests.join('、');
    return Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.matchSuccess,
      title: '興趣配對成功',
      subtitle: '你和$userName都喜歡$interestText',
      description: description,
      timestamp: DateTime.now(),
      userId: userId,
      userName: userName,
      matchedInterests: matchedInterests,
    );
  }
} 