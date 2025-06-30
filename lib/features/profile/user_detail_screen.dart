import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

class UserDetailScreen extends StatefulWidget {
  final String uid;
  final bool showAsFlag;

  const UserDetailScreen({
    super.key,
    required this.uid,
    this.showAsFlag = false,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final ref = FirebaseDatabase.instance.ref('users/${widget.uid}');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = '找不到用戶資料';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '載入資料時發生錯誤: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showAsFlag ? '互助旗' : '用戶資料'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // 🎯 如果未登入，返回登入頁面；已登入則返回首頁
              context.go(isLoggedIn ? '/' : '/login');
            }
          },
        ),
        actions: [
          // 🔐 如果未登入，顯示登入按鈕
          if (!isLoggedIn)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                '登入',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 🔔 未登入用戶提示
          if (!isLoggedIn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您正在以訪客身份瀏覽。登入後可使用更多功能！',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('立即登入'),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('載入中...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('重新載入'),
            ),
          ],
        ),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text('找不到用戶資料'),
      );
    }

    return _buildUserInfo();
  }

  Widget _buildUserInfo() {
    final name = userData!['name'] ?? 'Unknown User';
    final learnerBirth = userData!['learner_birth'] ?? 1980;
    final learnerHabit = userData!['learner_habit'] ?? '未知';
    final learnerRole = userData!['learner_role'] ?? '未知';
    final learnerType = userData!['learner_type'] ?? '未知';
    final address = userData!['address'] ?? '未知地區';
    final connectMe = userData!['connect_me'] ?? '';
    final share = userData!['share'] ?? '';
    final note = userData!['note'] ?? '';
    final photoURL = userData!['photoURL'];
    final availableTime = userData!['available_time'] ?? '';
    final oldestChildBirth = userData!['oldest_child_birth'] ?? '';
    final youngestChildBirth = userData!['youngest_child_birth'] ?? '';

    // 計算年齡
    final currentYear = DateTime.now().year;
    final age = currentYear - (learnerBirth is String ? int.tryParse(learnerBirth) ?? 1980 : learnerBirth);

    // 解析座標
    LatLng? location;
    if (userData!['latlngColumn'] != null && userData!['latlngColumn'] is String) {
      try {
        final coordinates = userData!['latlngColumn'].split(',');
        if (coordinates.length == 2) {
          location = LatLng(
            double.parse(coordinates[0].trim()),
            double.parse(coordinates[1].trim()),
          );
        }
      } catch (e) {
        // 座標解析失敗
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用戶頭像和基本資訊
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: photoURL != null && photoURL.isNotEmpty
                      ? NetworkImage(photoURL)
                      : null,
                  child: photoURL == null || photoURL.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '年齡: 約 $age 歲',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 詳細資訊卡片
          _buildInfoCard('基本資訊', [
            _buildInfoRow(Icons.work, '身份', learnerRole),
            _buildInfoRow(Icons.school, '自學型態', learnerType),
            _buildInfoRow(Icons.location_on, '地區', address),
            _buildInfoRow(Icons.interests, '興趣', learnerHabit),
          ]),

          const SizedBox(height: 16),

          if (availableTime.isNotEmpty)
            _buildInfoCard('時間安排', [
              _buildInfoRow(Icons.schedule, '有空時段', availableTime),
            ]),

          const SizedBox(height: 16),

          if (oldestChildBirth.isNotEmpty || youngestChildBirth.isNotEmpty)
            _buildInfoCard('孩子資訊', [
              if (oldestChildBirth.isNotEmpty)
                _buildInfoRow(Icons.child_care, '最大孩子出生年', oldestChildBirth),
              if (youngestChildBirth.isNotEmpty)
                _buildInfoRow(Icons.child_care, '最小孩子出生年', youngestChildBirth),
            ]),

          const SizedBox(height: 16),

          if (share.isNotEmpty)
            _buildInfoCard('分享技能', [
              _buildInfoRow(Icons.share, '可分享', share),
            ]),

          const SizedBox(height: 16),

          if (connectMe.isNotEmpty)
            _buildInfoCard('聯絡方式', [
              _buildInfoRow(Icons.contact_mail, '聯絡我', connectMe),
            ]),

          const SizedBox(height: 16),

          if (note.isNotEmpty)
            _buildInfoCard('自我介紹', [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  note,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ]),

          const SizedBox(height: 16),

          if (location != null)
            _buildInfoCard('位置資訊', [
              _buildInfoRow(
                Icons.gps_fixed,
                '座標',
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
              ),
            ]),

          const SizedBox(height: 24),

          // 動作按鈕
          Row(
            children: [
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {

                                         // 取得當前用戶的latlng
                     final latlng = userData!['latlngColumn'];
                     context.push('/map_detail/$latlng');
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('在地圖上查看'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
} 