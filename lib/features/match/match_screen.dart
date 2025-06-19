import 'package:flutter/material.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int filterIndex = 0;
  final List<String> filters = ['興趣配對', '位置配對', '技能配對', '隨機配對'];

  // 假資料
  final List<Map<String, dynamic>> users = [
    {
      'name': '小安',
      'age': 15,
      'distance': '1.3 km',
      'match': 0.95,
      'intro': '我是一直熱愛學習的人，希望能找到一起進步的夥伴！',
      'interests': ['音樂', '藝術', '文學'],
      'skills': ['英文對話', '日文基礎'],
    },
    {
      'name': '小杰',
      'age': 18,
      'distance': '2.6 km',
      'match': 0.85,
      'intro': '我是一個熱愛學習的人，希望能找到一起進步的夥伴！',
      'interests': ['程式設計', '數學', '物理'],
      'skills': ['Flutter開發', 'Python程式設計'],
    },
    // ...可再加更多假資料
  ];
  int currentIndex = 0;
  bool matched = false;

  void _showUserInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange[200],
                          child: Text(
                            users[currentIndex]['name'][0],
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              users[currentIndex]['name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${users[currentIndex]['age']} 歲',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('詳細資訊', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Text('配對分析', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                      Text('・配對分析：${(users[currentIndex]['match'] * 100).toInt()}%'),
                      Text('・距離：${users[currentIndex]['distance']}'),
                      Text('・共同興趣：${(users[currentIndex]['interests'] as List).join('、')}'),
                      const SizedBox(height: 16),
                      Text('興趣愛好', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                      ...List.generate(users[currentIndex]['interests'].length, (i) => Text('・${users[currentIndex]['interests'][i]}')),
                      const SizedBox(height: 16),
                      Text('專長技能', style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                      ...List.generate(users[currentIndex]['skills'].length, (i) => Text('・${users[currentIndex]['skills'][i]}')),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.message),
                              label: const Text('發送訊息'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('表示興趣'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[100], foregroundColor: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextUser() {
    setState(() {
      matched = false;
      if (users.length > 1) {
        currentIndex = (currentIndex + 1) % users.length;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final user = users[currentIndex];
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
          Container(
            color: Colors.orange[50],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.people, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('智能配對系統',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(filters.length, (i) {
                    final selected = filterIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              selected ? Colors.orange : Colors.white,
                          foregroundColor:
                              selected ? Colors.white : Colors.orange,
                          side: BorderSide(
                              color:
                                  Colors.orange.withAlpha(((selected ? 0 : 1) * 255).toInt())),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => setState(() => filterIndex = i),
                        child: Text(filters[i]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.orange[200],
                        child: Text(user['name'][0],
                            style: const TextStyle(
                                fontSize: 32,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22)),
                            Text('${user['age']} 歲',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            Text('距離 ${user['distance']}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black38)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('${(user['match'] * 100).toInt()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user['intro'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.interests,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: user['interests']
                              .map<Widget>((t) => Chip(
                                    label: Text(t),
                                    backgroundColor: Colors.orange[100],
                                    labelStyle: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: user['skills']
                              .map<Widget>((t) => Chip(
                                    label: Text(t),
                                    backgroundColor: Colors.red[50],
                                    labelStyle: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  if (matched)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Icon(Icons.favorite, color: Colors.pink, size: 48),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SquareIconButton(
              color: const Color(0xFFFF5722), // 紅色
              icon: const Icon(Icons.close, color: Colors.white, size: 36),
              onTap: _nextUser,
            ),
            SquareIconButton(
              color: Colors.orange,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.info, color: Colors.orange, size: 24),
                ],
              ),
              onTap: () => _showUserInfoBottomSheet(context),
            ),
            SquareIconButton(
              color: Colors.orange,
              icon: const Icon(Icons.favorite, color: Colors.white, size: 32),
              onTap: _matchSuccess,
            ),
          ],
        ),
      ),
    );
  }
}

class SquareIconButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback onTap;
  const SquareIconButton({super.key, required this.color, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(child: icon),
        ),
      ),
    );
  }
}
