import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int filterIndex = 0;
  final List<String> filters = ['全部', '學習夥伴', '導師', '同興趣'];

  // 假資料
  final List<Map<String, dynamic>> users = [
    {
      'name': '小雅',
      'age': 24,
      'distance': '0.9km',
      'tag': '物理',
      'type': '導師',
      'color': Colors.orange
    },
    {
      'name': '小強',
      'age': 23,
      'distance': '1.2km',
      'tag': '數學',
      'type': '同興趣',
      'color': Colors.deepOrange
    },
    {
      'name': '小美',
      'age': 22,
      'distance': '1.5km',
      'tag': '英文',
      'type': '學習夥伴',
      'color': Colors.orange
    },
    {
      'name': '小安',
      'age': 21,
      'distance': '2.0km',
      'tag': '化學',
      'type': '同興趣',
      'color': Colors.deepOrange
    },
    {
      'name': '小華',
      'age': 20,
      'distance': '2.5km',
      'tag': '生物',
      'type': '導師',
      'color': Colors.orange
    },
  ];

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
                    Icon(Icons.location_on, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('附近的學習夥伴',
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
                                  Colors.orange.withOpacity(selected ? 0 : 1)),
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
          // 假地圖區
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: Text('（地圖區，僅示意）',
                          style:
                              TextStyle(color: Colors.orange, fontSize: 16))),
                ),
                // 假標記
                ...List.generate(users.length, (i) {
                  final user = users[i];
                  return Positioned(
                    left: 60.0 + i * 30,
                    top: 60.0 + (i % 2) * 40,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: user['color'],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ],
                          ),
                          child: Text(user['name'],
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }),
                // 我的定位
                const Positioned(
                  left: 180,
                  top: 120,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepOrange,
                        child: Icon(Icons.my_location, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text('我的位置',
                          style: TextStyle(
                              fontSize: 12, color: Colors.deepOrange)),
                    ],
                  ),
                ),
                // 右側功能按鈕
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.orange,
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.orange,
                        onPressed: () {},
                        child: const Icon(Icons.grid_view_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 附近用戶列表
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('附近用戶 (${users.length})',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final user = users[i];
                        return ListTile(
                          leading: CircleAvatar(
                              backgroundColor: user['color'],
                              child: const Icon(Icons.person,
                                  color: Colors.white)),
                          title: Text('${user['name']} (${user['age']}歲)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${user['distance']}・${user['tag']}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(user['type'],
                                style: TextStyle(
                                    color: user['color'],
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
