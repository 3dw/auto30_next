import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';
import 'package:auto30_next/features/home/providers/activity_provider.dart';
import 'package:auto30_next/features/learning_center/presentation/screens/learning_center_screen.dart';
import 'package:auto30_next/features/quick_practice/presentation/screens/quick_practice_screen.dart';
import 'package:auto30_next/features/social/presentation/screens/social_main_screen.dart';
import 'package:auto30_next/shared/widgets/activity_card.dart';
import 'package:auto30_next/shared/models/activity_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _HomeAppBar(),
      ),
      body: const _HomeBody(),
      floatingActionButton: _SocialFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        'Auto30 - 自主學習促進會',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.grid_view_rounded),
        //   onPressed: () {},
        // ),
        IconButton(
          icon: const Icon(Icons.qr_code),
          onPressed: () {
            context.push('/qr');
          },
        ),
        _UserMenuButton(),
      ],
      elevation: 0,
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _WelcomeSection(),
          const _AnnouncementSection(),
          const _QuickFeatureSection(),
          const _RecentActivitySection(),
          const _PlatformFeatureSection(),
          const _BottomActionSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('歡迎使用 Auto30',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          const Text('一個促進自主學習交流的平台', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _AnnouncementSection extends StatelessWidget {
  const _AnnouncementSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha((0.9 * 255).toInt()),
            Theme.of(context).colorScheme.secondary.withAlpha((0.7 * 255).toInt())
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('歡迎來到自學3.0',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 4),
          Text('透過地理位置、興趣與專長，找到志同道合的朋友',
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }
}

class _QuickFeatureSection extends StatelessWidget {
  const _QuickFeatureSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('快速功能',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange)),
        ),
        Row(
          children: [
            Expanded(
              child: _QuickFeatureCard(
                  icon: Icons.location_on, title: '附近的人', subtitle: '查看地圖'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickFeatureCard(
                  icon: Icons.shuffle, title: '隨機配對', subtitle: '找新朋友'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickFeatureCard(
                  icon: Icons.flag, title: '我的互助旗', subtitle: '編輯資料'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickFeatureCard(
                  icon: Icons.qr_code, title: '我的QR碼', subtitle: '分享資料'),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _QuickFeatureCard(
      {required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    
    // 根據標題決定導航目標
    void _onTap() {
      switch (title) {
        case '附近的人':
          context.push('/map');
          break;
        case '隨機配對':
          context.push('/match');
          break;
        case '我的互助旗':
          context.push('/profile');
          break;
        case '我的QR碼':
          context.push('/qr');
          break;
      }
    }
    
    return Card(
      color: isWide ? const Color(0xFFFFFCF7) : Theme.of(context).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isWide ? const BorderSide(color: Color(0xFFFF9800), width: 1.2) : BorderSide.none,
      ),
      elevation: isWide ? 4 : 1,
      shadowColor: isWide ? Colors.orange.withOpacity(0.12) : null,
      child: InkWell(
        onTap: _onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatefulWidget {
  const _RecentActivitySection();
  
  @override
  State<_RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<_RecentActivitySection> {
  @override
  void initState() {
    super.initState();
    // 初始化活動數據
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final recentActivities = activityProvider.getRecentActivities(5);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '最近活動',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  if (activityProvider.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activityProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                ],
              ),
            ),
            
                        // 活動列表
            if (activityProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // 檢查是否有符合條件的新朋友活動，如果沒有則顯示提示訊息
              if (!activityProvider.hasQualifiedNewFriends())
                _NoQualifiedNewFriendsCard(),
              
              // 顯示其他活動
              if (recentActivities.isEmpty && activityProvider.hasQualifiedNewFriends())
                const _EmptyActivityState()
              else
                ...recentActivities.map((activity) => ActivityCard(
                  activity: activity,
                  onMarkAsRead: () => activityProvider.markAsRead(activity.id),
                )),
            ],
              
              // 查看更多按鈕
              if (recentActivities.isNotEmpty && recentActivities.length >= 5)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: () => context.push('/activities'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('查看更多活動'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暫無最近活動',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '當有新朋友加入、附近有學習聚會或配對成功時，\n活動會在這裡顯示',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NoQualifiedNewFriendsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 圖示
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // 內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '新朋友加入',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '30天內沒有新註冊且有升起互助旗的新朋友',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformFeatureSection extends StatelessWidget {
  const _PlatformFeatureSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('平台特色',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        ..._platformFeatures.map((feature) => _FeatureCard(feature: feature)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;
  const _FeatureCard({required this.feature});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(feature['icon'] as IconData,
            color: Theme.of(context).colorScheme.primary, size: 28),
        title: Text(feature['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(feature['subtitle'] as String),
      ),
    );
  }
}

const _platformFeatures = [
  {
    'icon': Icons.location_on,
    'title': '地理位置配對',
    'subtitle': '根據你的位置找到附近的朋友',
  },
  {
    'icon': Icons.groups,
    'title': '興趣專長媒合',
    'subtitle': '透過共同興趣和專長建立連結',
  },
  {
    'icon': Icons.flag,
    'title': '互助旗系統',
    'subtitle': '公開展示你的學習需求和能力',
  },
  {
    'icon': Icons.shield,
    'title': '安全隱私保護',
    'subtitle': '完善的隱私設定和安全機制',
  },
];

class _BottomActionSection extends StatelessWidget {
  const _BottomActionSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
            Theme.of(context).colorScheme.primary.withAlpha((0.05 * 255).toInt())
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text('開始你的 Flutter 學習之旅',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LearningCenterScreen()),
                    );
                  },
                  icon: const Icon(Icons.school),
                  label: const Text('學習中心'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const QuickPracticeScreen()),
                    );
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('快速練習'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('點擊「學習中心」開始完整的教學指南和互動練習',
              style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _SocialFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SocialMainScreen()),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      icon: const Icon(Icons.groups),
      label: const Text('完整社交功能'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            // 跳轉到個人資料頁
            context.push('/profile');
            break;
          case 'settings':
            // 跳轉到設定頁面
            context.push('/settings');
            break;
          case 'logout':
            // 顯示登出確認對話框
            _showLogoutDialog(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.orange),
              SizedBox(width: 8),
              Text('個人資料'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.orange),
              SizedBox(width: 8),
              Text('設定'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('登出'),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認登出'),
          content: const Text('確定要登出嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthProvider>().signOut();
              },
              child: const Text('登出'),
            ),
          ],
        );
      },
    );
  }
}
