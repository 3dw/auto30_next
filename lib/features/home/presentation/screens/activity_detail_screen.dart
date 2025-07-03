import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/shared/models/activity_model.dart';
import 'package:auto30_next/features/home/providers/activity_provider.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String activityId;
  
  const ActivityDetailScreen({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activity = activityProvider.activities
            .firstWhere((a) => a.id == activityId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(activity.title),
            backgroundColor: activity.color,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (!activity.isRead)
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () {
                    activityProvider.markAsRead(activity.id);
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 頭部背景
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activity.color,
                        activity.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          activity.icon,
                          size: 48,
                          color: activity.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.timeAgo,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 內容區域
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息
                      _buildInfoSection(
                        context,
                        title: '活動信息',
                        children: [
                          _buildInfoItem(
                            icon: Icons.info_outline,
                            title: '描述',
                            content: activity.subtitle,
                          ),
                          if (activity.description != null)
                            _buildInfoItem(
                              icon: Icons.description,
                              title: '詳細描述',
                              content: activity.description!,
                            ),
                        ],
                      ),
                      
                      // 特殊內容（基於活動類型）
                      if (activity.type == ActivityType.newFriend)
                        _buildNewFriendSection(context, activity),
                      
                      if (activity.type == ActivityType.nearbyEvent)
                        _buildNearbyEventSection(context, activity),
                      
                      if (activity.type == ActivityType.matchSuccess)
                        _buildMatchSuccessSection(context, activity),
                      
                      // 操作按鈕
                      const SizedBox(height: 24),
                      _buildActionButtons(context, activity),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewFriendSection(BuildContext context, Activity activity) {
    return _buildInfoSection(
      context,
      title: '新朋友信息',
      children: [
        if (activity.userName != null)
          _buildInfoItem(
            icon: Icons.person,
            title: '用戶名',
            content: activity.userName!,
          ),
        _buildInfoItem(
          icon: Icons.access_time,
          title: '加入時間',
          content: activity.timeAgo,
        ),
      ],
    );
  }

  Widget _buildNearbyEventSection(BuildContext context, Activity activity) {
    return _buildInfoSection(
      context,
      title: '學習聚會信息',
      children: [
        if (activity.distance != null)
          _buildInfoItem(
            icon: Icons.location_on,
            title: '距離',
            content: activity.distance!,
          ),
        if (activity.latitude != null && activity.longitude != null)
          _buildInfoItem(
            icon: Icons.map,
            title: '位置',
            content: '緯度: ${activity.latitude?.toStringAsFixed(4)}, 經度: ${activity.longitude?.toStringAsFixed(4)}',
          ),
      ],
    );
  }

  Widget _buildMatchSuccessSection(BuildContext context, Activity activity) {
    return _buildInfoSection(
      context,
      title: '配對信息',
      children: [
        if (activity.userName != null)
          _buildInfoItem(
            icon: Icons.person,
            title: '配對對象',
            content: activity.userName!,
          ),
        if (activity.matchedInterests != null && activity.matchedInterests!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '共同興趣',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: activity.matchedInterests!
                            .map((interest) => Chip(
                                  label: Text(interest),
                                  backgroundColor: Colors.orange.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Activity activity) {
    return Column(
      children: [
        // 主要操作按鈕
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handlePrimaryAction(context, activity),
            icon: Icon(_getPrimaryActionIcon(activity.type)),
            label: Text(_getPrimaryActionText(activity.type)),
            style: ElevatedButton.styleFrom(
              backgroundColor: activity.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 次要操作按鈕
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // 分享活動
                  _shareActivity(context, activity);
                },
                icon: const Icon(Icons.share),
                label: const Text('分享'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // 刪除活動
                  _deleteActivity(context, activity);
                },
                icon: const Icon(Icons.delete),
                label: const Text('刪除'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getPrimaryActionIcon(ActivityType type) {
    switch (type) {
      case ActivityType.newFriend:
        return Icons.person;
      case ActivityType.nearbyEvent:
        return Icons.map;
      case ActivityType.matchSuccess:
        return Icons.chat;
    }
  }

  String _getPrimaryActionText(ActivityType type) {
    switch (type) {
      case ActivityType.newFriend:
        return '查看用戶資料';
      case ActivityType.nearbyEvent:
        return '查看地圖位置';
      case ActivityType.matchSuccess:
        return '開始聊天';
    }
  }

  void _handlePrimaryAction(BuildContext context, Activity activity) {
    switch (activity.type) {
      case ActivityType.newFriend:
        if (activity.userId != null) {
          context.push('/profile/${activity.userId}');
        }
        break;
      case ActivityType.nearbyEvent:
        if (activity.latitude != null && activity.longitude != null) {
          context.push('/map?lat=${activity.latitude}&lng=${activity.longitude}');
        } else {
          context.push('/map');
        }
        break;
      case ActivityType.matchSuccess:
        if (activity.userId != null) {
          // 這裡可以導航到聊天頁面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('聊天功能尚未實現')),
          );
        }
        break;
    }
  }

  void _shareActivity(BuildContext context, Activity activity) {
    // 實現分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享活動：${activity.title}'),
        action: SnackBarAction(
          label: '確定',
          onPressed: () {},
        ),
      ),
    );
  }

  void _deleteActivity(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除活動'),
        content: const Text('確定要刪除這個活動嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ActivityProvider>().removeActivity(activity.id);
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }
} 