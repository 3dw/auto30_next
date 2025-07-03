import 'package:flutter/material.dart';
import 'package:auto30_next/shared/models/activity_model.dart';
import 'package:go_router/go_router.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final bool showActions;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onMarkAsRead,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: activity.isRead ? 1 : 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: !activity.isRead
            ? BorderSide(
                color: activity.color.withOpacity(0.3),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主要內容行
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 活動圖示
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activity.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 活動內容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 標題和時間
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: !activity.isRead
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              activity.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // 副標題
                        Text(
                          activity.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        
                        // 描述（如果存在）
                        if (activity.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            activity.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 未讀指示器
                  if (!activity.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: activity.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              
              // 特殊內容（基於活動類型）
              if (activity.type == ActivityType.matchSuccess &&
                  activity.matchedInterests != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: activity.matchedInterests!
                      .map((interest) => _buildInterestChip(interest))
                      .toList(),
                ),
              ],
              
              // 操作按鈕
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!activity.isRead)
                      TextButton(
                        onPressed: onMarkAsRead,
                        child: const Text('標記為已讀'),
                      ),
                    TextButton(
                      onPressed: () => _handleTap(context),
                      child: const Text('查看詳情'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Text(
        interest,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    // 根據活動類型決定導航行為
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
          context.push('/profile/${activity.userId}');
        }
        break;
    }
  }
}

// 活動列表組件
class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  final bool showActions;
  final Function(String)? onMarkAsRead;
  final bool isLoading;

  const ActivityList({
    super.key,
    required this.activities,
    this.showActions = false,
    this.onMarkAsRead,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '暫無活動',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '當有新的活動時，會在這裡顯示',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityCard(
          activity: activity,
          showActions: showActions,
          onMarkAsRead: onMarkAsRead != null
              ? () => onMarkAsRead!(activity.id)
              : null,
        );
      },
    );
  }
} 