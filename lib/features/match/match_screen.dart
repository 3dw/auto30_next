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
  final Map<String, dynamic> user = {
    'name': '小杰',
    'age': 18,
    'distance': '2.6 km',
    'match': 0.85,
    'intro': '我是一個熱愛學習的人，希望能找到一起進步的夥伴！',
    'interests': ['程式設計', '數學', '物理'],
    'skills': ['Flutter開發', 'Python程式設計'],
  };

  @override
  Widget build(BuildContext context) {
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
          // 用戶卡片
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orange.withAlpha((0.08 * 255).toInt()),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('個人介紹',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8, bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(user['intro'],
                          style: const TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.interests, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('興趣愛好',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Wrap(
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
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.red),
                        SizedBox(width: 8),
                        Text('專長技能',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Wrap(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 底部三大按鈕
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              heroTag: 'no',
              backgroundColor: Colors.orange,
              onPressed: () {},
              child: const Icon(Icons.close, size: 32),
            ),
            FloatingActionButton(
              heroTag: 'info',
              backgroundColor: Colors.orange,
              onPressed: () {},
              child: const Icon(Icons.info, size: 32),
            ),
            FloatingActionButton(
              heroTag: 'yes',
              backgroundColor: Colors.orange,
              onPressed: () {},
              child: const Icon(Icons.favorite, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
