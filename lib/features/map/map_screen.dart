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
    // 篩選後的用戶
    final filteredUsers = filterIndex == 0
        ? users
        : users.where((u) => u['type'] == filters[filterIndex]).toList();

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
          // 篩選區
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
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      '附近的學習夥伴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.orange),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('定位中...')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filters.length, (i) {
                      final selected = filterIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filters[i]),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() => filterIndex = i);
                          },
                          selectedColor: Colors.orange.shade100,
                          checkmarkColor: Colors.orange,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // 地圖區
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Stack(
                children: [
                  // 背景地圖樣式
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // 假標記
                  ...List.generate(filteredUsers.length, (i) {
                    final user = filteredUsers[i];
                    return Positioned(
                      left: 60.0 + i * 30,
                      top: 60.0 + (i % 2) * 40,
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: user['color'],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // 我的位置標記
                  const Positioned(
                    left: 180,
                    top: 120,
                    child: _MyLocationMarker(),
                  ),
                  // 地圖控制按鈕
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: "zoom_in",
                          onPressed: () {},
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.zoom_in, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: "zoom_out",
                          onPressed: () {},
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.zoom_out, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 附近用戶列表
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '附近用戶 (${filteredUsers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, i) {
                        final user = filteredUsers[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user['color'],
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              '${user['name']} (${user['age']}歲)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${user['distance']}・${user['tag']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user['color'].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user['type'],
                                style: TextStyle(
                                  color: user['color'],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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

class _MyLocationMarker extends StatelessWidget {
  const _MyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
            size: 30,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '我的位置',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
