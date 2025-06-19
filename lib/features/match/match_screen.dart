import 'package:flutter/material.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with TickerProviderStateMixin {
  int filterIndex = 0;
  final List<String> filters = ['興趣配對', '位置配對', '技能配對', '隨機配對'];

  // 假資料
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
    // ...可再加更多假資料
  ];
  int currentIndex = 0;
  bool matched = false;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

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

  void _showUserInfoBottomSheet(BuildContext context) {
    final user = users[currentIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CandidateDetailSheet(user: user),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = users[currentIndex];
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('自學社交平台'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // 頂部配對類型選擇
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.people, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '智能配對系統',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.asMap().entries.map((entry) {
                      final i = entry.key;
                      final type = entry.value;
                      final isSelected = filterIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              filterIndex = i;
                              // 可根據 type 重新載入資料
                            });
                          },
                          selectedColor: Colors.orange.shade100,
                          checkmarkColor: Colors.orange,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // 配對卡片區域
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 500 : double.infinity,
                  maxHeight: double.infinity,
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          (1 - _slideAnimation.value) * MediaQuery.of(context).size.width,
                          0,
                        ),
                        child: _MatchingCard(
                          user: user,
                          matched: matched,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 底部操作按鈕
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchingCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool matched;
  const _MatchingCard({required this.user, required this.matched});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頭像和基本資訊
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isDesktop ? 50 : 40,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      user['name'][0],
                      style: TextStyle(
                        fontSize: isDesktop ? 36 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(
                            fontSize: isDesktop ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user['age']} 歲',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '距離 ${user['distance'].toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 配對分數
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 12, 
                      vertical: isDesktop ? 8 : 6
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(user['match']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${user['match']}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              // 個人介紹
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '個人介紹',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 18 : 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user['intro'],
                      style: TextStyle(fontSize: isDesktop ? 16 : 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 20 : 16),
              // 興趣標籤
              if ((user['interests'] as List).isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.interests, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      '興趣愛好',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: isDesktop ? 12 : 8,
                  runSpacing: isDesktop ? 12 : 8,
                  children: (user['interests'] as List).map<Widget>((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 12, 
                        vertical: isDesktop ? 8 : 6
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                          fontSize: isDesktop ? 15 : 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: isDesktop ? 20 : 16),
              ],
              // 技能標籤
              if ((user['skills'] as List).isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      '專長技能',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: isDesktop ? 12 : 8,
                  runSpacing: isDesktop ? 12 : 8,
                  children: (user['skills'] as List).map<Widget>((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 12, 
                        vertical: isDesktop ? 8 : 6
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange.shade300),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                          fontSize: isDesktop ? 15 : 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (matched) ...[
                SizedBox(height: isDesktop ? 20 : 16),
                Center(
                  child: Icon(
                    Icons.favorite, 
                    color: Colors.pink, 
                    size: isDesktop ? 56 : 48
                  ),
                ),
              ],
              // 底部間距確保內容不會被遮擋
              SizedBox(height: isDesktop ? 20 : 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.orange;
    if (score >= 60) return Colors.orange.shade600;
    return Colors.deepOrange;
  }
}

class _CandidateDetailSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  const _CandidateDetailSheet({required this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 頂部標題
          Row(
            children: [
              const Text(
                '詳細資訊',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          // 詳細內容
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本資訊
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            user['name'][0],
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${user['age']} 歲'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 配對分析
                  _buildSection(
                    '配對分析',
                    [
                      '配對分數：${user['match']}%',
                      '距離：${user['distance'].toStringAsFixed(1)} km',
                      '共同興趣：${(user['interests'] as List).take(2).join(', ')}',
                    ],
                  ),
                  // 興趣愛好
                  _buildSection(
                    '興趣愛好',
                    (user['interests'] as List).cast<String>(),
                  ),
                  // 專長技能
                  _buildSection(
                    '專長技能',
                    (user['skills'] as List).cast<String>(),
                  ),
                  // 個人介紹
                  _buildSection(
                    '個人介紹',
                    [user['intro']],
                  ),
                ],
              ),
            ),
          ),
          // 底部按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('向 ${user['name']} 發送訊息')),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('發送訊息'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('向 ${user['name']} 發送交友邀請')),
                    );
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('表示興趣'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: Text(item)),
            ],
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
