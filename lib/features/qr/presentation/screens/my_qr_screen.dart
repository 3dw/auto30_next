import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> with TickerProviderStateMixin {
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    
    // 🎯 這裡是關鍵！QR 碼的內容就是動態路由的 URL
    // 當別人掃描這個 QR 碼時，會跳轉到 /user/{你的uid} 這個動態路由
    final qrData = 'https://auto30next.alearn.org.tw/user/$uid';
    
    // 📝 教學重點：
    // 1. uid 是每個用戶的唯一識別碼（像學號一樣）
    // 2. /user/$uid 就是動態路由，$uid 會被替換成實際的用戶ID
    // 3. 例如：/user/abc123 就會顯示 abc123 這個用戶的個人頁面
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        title: const Text(
          '我的專屬 QR 碼',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code),
              text: '我的 QR 碼',
            ),
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: '掃描 QR 碼',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyQRCodeTab(isDesktop: isDesktop, qrData: qrData),
          ScanQRCodeTab(isDesktop: isDesktop),
        ],
      ),
    );
  }
}

class MyQRCodeTab extends StatefulWidget {
  final bool isDesktop;
  final String qrData;
  
  const MyQRCodeTab({super.key, required this.isDesktop, required this.qrData});

  @override
  State<MyQRCodeTab> createState() => _MyQRCodeTabState();
}

class _MyQRCodeTabState extends State<MyQRCodeTab> {
  bool qrEnabled = true;
  bool showContact = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isDesktop ? 24 : 16),
      child: Column(
        children: [
          // QR 碼展示區域
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.isDesktop ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '我的互助旗 QR 碼',
                  style: TextStyle(
                    fontSize: widget.isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: widget.isDesktop ? 24 : 20),
                
                // 模擬 QR 碼
                Container(
                  width: widget.isDesktop ? 250 : 200,
                  height: widget.isDesktop ? 250 : 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: QrImageView(
                    data: widget.qrData,
                    version: QrVersions.auto,
                    size: widget.isDesktop ? 250 : 200,
                  ),
                ),
                
                SizedBox(height: widget.isDesktop ? 20 : 16),
                
                Text(
                  '掃描此 QR 碼即可查看我的互助旗',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: widget.isDesktop ? 16 : 14,
                  ),
                ),
                
                SizedBox(height: widget.isDesktop ? 24 : 20),
                
                // 個人資訊預覽
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(widget.isDesktop ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: widget.isDesktop ? 40 : 30,
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.person, 
                          color: Colors.white, 
                          size: widget.isDesktop ? 40 : 30
                        ),
                      ),
                      SizedBox(height: widget.isDesktop ? 12 : 8),
                      Text(
                        '學習者',
                        style: TextStyle(
                          fontSize: widget.isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '16 歲 • 熱愛學習',
                        style: TextStyle(fontSize: widget.isDesktop ? 16 : 14),
                      ),
                      SizedBox(height: widget.isDesktop ? 12 : 8),
                      Wrap(
                        spacing: widget.isDesktop ? 12 : 8,
                        children: [
                          Chip(
                            label: Text(
                              '程式設計',
                              style: TextStyle(fontSize: widget.isDesktop ? 14 : 12),
                            ),
                            backgroundColor: Colors.orange,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          Chip(
                            label: Text(
                              '數學',
                              style: TextStyle(fontSize: widget.isDesktop ? 14 : 12),
                            ),
                            backgroundColor: Colors.deepOrange,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: widget.isDesktop ? 32 : 24),
          
          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveQRCode(context),
                  icon: const Icon(Icons.save),
                  label: const Text('保存到相簿'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: widget.isDesktop ? 16 : 12),
                  ),
                ),
              ),
              SizedBox(width: widget.isDesktop ? 16 : 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareQRCode(context),
                  icon: const Icon(Icons.share),
                  label: const Text('分享 QR 碼'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: widget.isDesktop ? 16 : 12),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: widget.isDesktop ? 32 : 20),
          
          // QR 碼使用說明
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: widget.isDesktop ? 12 : 8),
                    Text(
                      '使用說明',
                      style: TextStyle(
                        fontSize: widget.isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.isDesktop ? 16 : 12),
                UsageItem(
                  icon: Icons.camera_alt,
                  text: '保存 QR 碼圖片到手機相簿',
                  isDesktop: widget.isDesktop,
                ),
                UsageItem(
                  icon: Icons.share,
                  text: '分享給想認識的朋友',
                  isDesktop: widget.isDesktop,
                ),
                UsageItem(
                  icon: Icons.qr_code_scanner,
                  text: '朋友掃描後可查看你的互助旗',
                  isDesktop: widget.isDesktop,
                ),
                UsageItem(
                  icon: Icons.security,
                  text: '可隨時更新或停用 QR 碼',
                  isDesktop: widget.isDesktop,
                ),
              ],
            ),
          ),
          
          SizedBox(height: widget.isDesktop ? 32 : 20),
          
          // 隱私設定
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: Colors.orange),
                    SizedBox(width: widget.isDesktop ? 12 : 8),
                    Text(
                      '隱私設定',
                      style: TextStyle(
                        fontSize: widget.isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.isDesktop ? 16 : 12),
                SwitchListTile(
                  title: Text(
                    '啟用 QR 碼',
                    style: TextStyle(fontSize: widget.isDesktop ? 16 : 14),
                  ),
                  subtitle: Text(
                    '其他人可以透過 QR 碼查看我的資料',
                    style: TextStyle(fontSize: widget.isDesktop ? 14 : 12),
                  ),
                  value: qrEnabled,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => qrEnabled = value),
                  dense: true,
                ),
                SwitchListTile(
                  title: Text(
                    '顯示聯絡方式',
                    style: TextStyle(fontSize: widget.isDesktop ? 16 : 14),
                  ),
                  subtitle: Text(
                    '在 QR 碼中包含聯絡資訊',
                    style: TextStyle(fontSize: widget.isDesktop ? 14 : 12),
                  ),
                  value: showContact,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => showContact = value),
                  dense: true,
                ),
                SizedBox(height: widget.isDesktop ? 12 : 8),
                Center(
                  child: TextButton(
                    onPressed: () => _regenerateQRCode(context),
                    child: Text(
                      '重新生成 QR 碼',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: widget.isDesktop ? 16 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveQRCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR 碼已保存到相簿'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareQRCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR 碼分享功能'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _regenerateQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新生成 QR 碼'),
        content: const Text('重新生成後，舊的 QR 碼將失效。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR 碼已重新生成'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}

class ScanQRCodeTab extends StatelessWidget {
  final bool isDesktop;
  
  const ScanQRCodeTab({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        children: [
          // 掃描區域
          Container(
            width: double.infinity,
            height: isDesktop ? 400 : 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // 相機預覽區域（模擬）
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade800, Colors.grey.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                
                // 掃描框
                Center(
                  child: Container(
                    width: isDesktop ? 250 : 200,
                    height: isDesktop ? 250 : 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: ScanFramePainter(),
                      size: Size(isDesktop ? 250 : 200, isDesktop ? 250 : 200),
                    ),
                  ),
                ),
                
                // 提示文字
                Positioned(
                  bottom: isDesktop ? 32 : 20,
                  left: 0,
                  right: 0,
                  child: Text(
                    '將 QR 碼對準掃描框',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isDesktop ? 32 : 24),
          
          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startScanning(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('開始掃描'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectFromGallery(context),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('從相簿選擇'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isDesktop ? 32 : 24),
          
          // 掃描歷史
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Text(
                      '最近掃描',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                ScanHistoryItem(
                  name: '小明',
                  time: '2 小時前',
                  action: '已加為好友',
                  isDesktop: isDesktop,
                ),
                ScanHistoryItem(
                  name: '小華',
                  time: '昨天',
                  action: '查看了資料',
                  isDesktop: isDesktop,
                ),
                ScanHistoryItem(
                  name: '小美',
                  time: '3 天前',
                  action: '已發送訊息',
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '查看全部歷史',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isDesktop ? 32 : 20),
          
          // 使用提示
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Text(
                      '掃描小貼士',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                UsageItem(
                  icon: Icons.center_focus_strong,
                  text: '將 QR 碼完整對準掃描框',
                  isDesktop: isDesktop,
                ),
                UsageItem(
                  icon: Icons.wb_sunny,
                  text: '確保光線充足，避免反光',
                  isDesktop: isDesktop,
                ),
                UsageItem(
                  icon: Icons.camera_alt,
                  text: '也可以從相簿選擇 QR 碼圖片',
                  isDesktop: isDesktop,
                ),
                UsageItem(
                  icon: Icons.security,
                  text: '只掃描信任來源的 QR 碼',
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startScanning(BuildContext context) {
    // 🎯 實際的掃描功能應該會掃描到類似這樣的 URL：
    // https://auto30next.alearn.org.tw/user/someUserId
    
    // 模擬掃描到的 QR 碼內容
    final scannedUrl = 'https://auto30next.alearn.org.tw/user/testUser123';
    
    // 📝 教學重點：從 URL 中提取用戶 ID
    // 例如：從 "https://auto30next.alearn.org.tw/user/testUser123" 
    // 提取出 "testUser123"
    final uri = Uri.parse(scannedUrl);
    final pathSegments = uri.pathSegments; // ['user', 'testUser123']
    
    if (pathSegments.length >= 2 && pathSegments[0] == 'user') {
      final scannedUserId = pathSegments[1]; // 'testUser123'
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('掃描成功！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: isDesktop ? 40 : 30,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.person, 
                  color: Colors.white, 
                  size: isDesktop ? 40 : 30
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                '發現互助旗！',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '用戶 ID: $scannedUserId',
                style: TextStyle(fontSize: isDesktop ? 16 : 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                
                // 🚀 這裡是關鍵！使用動態路由跳轉到被掃描用戶的個人頁面
                // context.push('/user/$scannedUserId') 會跳轉到動態路由
                context.push('/user/$scannedUserId');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在查看用戶資料...')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('查看詳情'),
            ),
          ],
        ),
      );
    } else {
      // 掃描到的不是有效的用戶 QR 碼
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無效的 QR 碼格式')),
      );
    }
  }

  void _selectFromGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('從相簿選擇 QR 碼圖片')),
    );
  }
}

class UsageItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDesktop;

  const UsageItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Row(
        children: [
          Icon(
            icon, 
            size: isDesktop ? 18 : 16, 
            color: Colors.orange.shade600
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanHistoryItem extends StatelessWidget {
  final String name;
  final String time;
  final String action;
  final bool isDesktop;

  const ScanHistoryItem({
    super.key,
    required this.name,
    required this.time,
    required this.action,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: isDesktop ? 20 : 16,
            backgroundColor: Colors.orange.shade100,
            child: Icon(
              Icons.person, 
              size: isDesktop ? 20 : 16, 
              color: Colors.orange
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// 自定義繪製 QR 碼樣式
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 繪製模擬的 QR 碼圖案
    final blockSize = size.width / 20;
    
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        // 隨機繪製黑色方塊來模擬 QR 碼
        if ((i + j) % 3 == 0 || (i * j) % 7 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * blockSize,
              j * blockSize,
              blockSize,
              blockSize,
            ),
            paint,
          );
        }
      }
    }

    // 繪製三個角落的定位標記
    _drawPositionMarker(canvas, paint, Offset.zero, blockSize);
    _drawPositionMarker(canvas, paint, Offset(13 * blockSize, 0), blockSize);
    _drawPositionMarker(canvas, paint, Offset(0, 13 * blockSize), blockSize);
  }

  void _drawPositionMarker(Canvas canvas, Paint paint, Offset offset, double blockSize) {
    // 外框
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, 7 * blockSize, 7 * blockSize),
      paint,
    );
    
    // 內部白色
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + blockSize,
        offset.dy + blockSize,
        5 * blockSize,
        5 * blockSize,
      ),
      Paint()..color = Colors.white,
    );
    
    // 中心黑色
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + 2 * blockSize,
        offset.dy + 2 * blockSize,
        3 * blockSize,
        3 * blockSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 掃描框繪製
class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 繪製四個角落的L形標記
    final cornerLength = 20.0;
    
    // 左上角
    canvas.drawLine(Offset(0, cornerLength), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(cornerLength, 0), paint);
    
    // 右上角
    canvas.drawLine(Offset(size.width - cornerLength, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);
    
    // 左下角
    canvas.drawLine(Offset(0, size.height - cornerLength), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    
    // 右下角
    canvas.drawLine(Offset(size.width - cornerLength, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
