import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool qrEnabled = true;
  bool showContact = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 假資料
    final user = {
      'name': '孫小明',
      'age': 16,
      'desc': '熱愛學習',
      'tags': ['程式設計', '數學'],
      'qrData': 'user:123456',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的專屬 QR 碼'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: '我的 QR 碼'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: '掃描 QR 碼'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 我的 QR 碼
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('${user['age']} 歲・${user['desc']}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (user['tags'] as List)
                      .map<Widget>((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (qrEnabled)
                  // TODO: QrImage 產生錯誤，暫時 block 起來
                  Container(
                    width: 180,
                    height: 180,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text('QR 產生器暫停',
                        style: TextStyle(color: Colors.black54)),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {/* 儲存到相簿 */},
                        icon: const Icon(Icons.save),
                        label: const Text('保存到相簿'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {/* 分享 QR 碼 */},
                        icon: const Icon(Icons.share),
                        label: const Text('分享 QR 碼'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.orange),
                          title: Text('使用說明',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text(
                            '• 保存 QR 碼圖片到手機相簿\n• 分享給想認識的朋友\n• 朋友掃描後可查看你的互助旗\n• 可隨時更新或停用 QR 碼'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(
                          leading: Icon(Icons.shield, color: Colors.orange),
                          title: Text('隱私設定',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SwitchListTile(
                          title: const Text('啟用 QR 碼'),
                          value: qrEnabled,
                          onChanged: (v) => setState(() => qrEnabled = v),
                          activeColor: Colors.orange,
                        ),
                        SwitchListTile(
                          title: const Text('顯示聯絡方式'),
                          value: showContact,
                          onChanged: (v) => setState(() => showContact = v),
                          activeColor: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {/* 重新生成 QR 碼 */},
                            child: const Text('重新生成 QR 碼',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 掃描 QR 碼
          Center(child: Text('Web 端暫不支援掃描 QR 碼')),
        ],
      ),
    );
  }
}
