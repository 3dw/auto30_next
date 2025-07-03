import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/shared/models/activity_model.dart';
import 'package:auto30_next/features/home/providers/activity_provider.dart';
import 'package:auto30_next/shared/widgets/activity_card.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活動列表'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Consumer<ActivityProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.done_all),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => provider.markAllAsRead(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = context.read<ActivityProvider>();
              switch (value) {
                case 'new_friend':
                  await provider.simulateNewFriend();
                  break;
                case 'nearby_event':
                  await provider.simulateNearbyEvent();
                  break;
                case 'match_success':
                  await provider.simulateMatchSuccess();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_friend',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('模擬新朋友'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'nearby_event',
                child: Row(
                  children: [
                    Icon(Icons.event, color: Colors.green),
                    SizedBox(width: 8),
                    Text('模擬附近聚會'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'match_success',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text('模擬配對成功'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('清空所有活動'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '新朋友'),
            Tab(text: '附近聚會'),
            Tab(text: '配對成功'),
          ],
        ),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActivityList(provider.activities),
              _buildActivityList(provider.activities
                  .where((a) => a.type == ActivityType.newFriend)
                  .toList()),
              _buildActivityList(provider.activities
                  .where((a) => a.type == ActivityType.nearbyEvent)
                  .toList()),
              _buildActivityList(provider.activities
                  .where((a) => a.type == ActivityType.matchSuccess)
                  .toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityList(List<Activity> activities) {
    if (activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暫無活動',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // 模擬刷新
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.read<ActivityProvider>().initialize();
        }
      },
      child: ListView.builder(
        itemCount: activities.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ActivityCard(
            activity: activity,
            showActions: true,
            onTap: () => _navigateToDetail(activity),
            onMarkAsRead: () => context.read<ActivityProvider>().markAsRead(activity.id),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Activity activity) {
    context.push('/activity/${activity.id}');
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有活動'),
        content: const Text('確定要清空所有活動嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ActivityProvider>().clearAllActivities();
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
} 