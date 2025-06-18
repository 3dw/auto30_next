import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';
import 'package:auto30_next/features/learning_center/presentation/screens/learning_center_screen.dart';
import 'package:auto30_next/features/quick_practice/presentation/screens/quick_practice_screen.dart';
import 'package:auto30_next/features/qr/presentation/screens/my_qr_screen.dart';
import 'package:auto30_next/features/social/presentation/screens/social_main_screen.dart';

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
        IconButton(
          icon: const Icon(Icons.grid_view_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.qr_code),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyQrScreen()),
            );
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
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('快速功能',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: const [
              _QuickFeatureCard(
                  icon: Icons.location_on, title: '附近的人', subtitle: '查看地圖'),
              _QuickFeatureCard(
                  icon: Icons.shuffle, title: '隨機配對', subtitle: '找新朋友'),
              _QuickFeatureCard(
                  icon: Icons.flag, title: '我的互助旗', subtitle: '編輯資料'),
              _QuickFeatureCard(
                  icon: Icons.qr_code, title: '我的QR碼', subtitle: '分享資料'),
            ],
          ),
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
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
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
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('最近活動',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        ..._recentActivities
            .map((activity) => _ActivityCard(activity: activity)),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityCard({required this.activity});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(activity['icon'] as IconData,
            color: Theme.of(context).colorScheme.primary, size: 28),
        title: Text(activity['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(activity['subtitle'] as String),
        trailing: Text(activity['time'] as String,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ),
    );
  }
}

const _recentActivities = [
  {
    'icon': Icons.person_add,
    'title': '新朋友加入',
    'subtitle': '小明剛剛註冊了平台',
    'time': '5分鐘前',
  },
  {
    'icon': Icons.event,
    'title': '附近的學習聚會',
    'subtitle': '距離你 500 公尺',
    'time': '1小時前',
  },
  {
    'icon': Icons.favorite,
    'title': '興趣配對成功',
    'subtitle': '你和小華都喜歡程式設計',
    'time': '3小時前',
  },
];

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
      icon: const Icon(Icons.account_circle_rounded),
      onSelected: (value) async {
        if (value == 'logout') {
          await context.read<AuthProvider>().signOut();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('登出'),
        ),
      ],
    );
  }
}
