import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugUserScreen extends StatefulWidget {
  const DebugUserScreen({super.key});

  @override
  State<DebugUserScreen> createState() => _DebugUserScreenState();
}

class _DebugUserScreenState extends State<DebugUserScreen> {
  final _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      const userId = 'eRZCNMNnyUO7nRAhidr0fd1K1ch1';
      final snapshot = await _database.child('users/$userId').get();
      
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '找不到用戶資料';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '載入失敗: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('調試用戶資料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '用戶資料分析',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 基本信息
                      _buildInfoCard('基本信息', {
                        '用戶名': _userData!['name'] ?? '未設定',
                        '地址': _userData!['address'] ?? '未設定',
                        'Email': _userData!['email'] ?? '未設定',
                      }),
                      
                      const SizedBox(height: 16),
                      
                      // 時間信息
                      _buildTimeInfo(),
                      
                      const SizedBox(height: 16),
                      
                      // 互助旗狀態
                      _buildFlagInfo(),
                      
                      const SizedBox(height: 16),
                      
                      // 新朋友活動條件檢查
                      _buildActivityConditionCheck(),
                      
                      const SizedBox(height: 16),
                      
                      // 所有欄位
                      _buildAllFieldsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...info.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    DateTime? lastUpdate;
    DateTime? creationTime;
    
    if (_userData!['lastUpdate'] != null) {
      lastUpdate = DateTime.fromMillisecondsSinceEpoch(_userData!['lastUpdate']);
    }
    if (_userData!['creationTime'] != null) {
      creationTime = DateTime.fromMillisecondsSinceEpoch(_userData!['creationTime']);
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '時間信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (lastUpdate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        '最後更新:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Text(lastUpdate.toString())),
                  ],
                ),
              ),
            if (creationTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        '創建時間:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Text(creationTime.toString())),
                  ],
                ),
              ),
            if (lastUpdate == null && creationTime == null)
              const Text('無法確定時間信息', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagInfo() {
    final flagDown = _userData!['flag_down'] as bool? ?? false;
    final hasFlag = !flagDown;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '互助旗狀態',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasFlag ? Icons.flag : Icons.flag_outlined,
                  color: hasFlag ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  hasFlag ? '互助旗升起' : '互助旗降下',
                  style: TextStyle(
                    color: hasFlag ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('flag_down: $flagDown'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityConditionCheck() {
    DateTime? registrationDate;
    if (_userData!['lastUpdate'] != null) {
      registrationDate = DateTime.fromMillisecondsSinceEpoch(_userData!['lastUpdate']);
    } else if (_userData!['creationTime'] != null) {
      registrationDate = DateTime.fromMillisecondsSinceEpoch(_userData!['creationTime']);
    }
    
    final flagDown = _userData!['flag_down'] as bool? ?? false;
    final hasFlag = !flagDown;
    
    final now = DateTime.now();
    final filterDate = now.subtract(const Duration(days: 2));
    final isRecent = registrationDate != null && registrationDate.isAfter(filterDate);
    final meetsConditions = isRecent && hasFlag;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新朋友活動條件檢查',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildConditionRow('註冊時間', registrationDate?.toString() ?? '未知', isRecent),
            _buildConditionRow('互助旗狀態', hasFlag ? '升起' : '降下', hasFlag),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: meetsConditions ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: meetsConditions ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    meetsConditions ? Icons.check_circle : Icons.cancel,
                    color: meetsConditions ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    meetsConditions ? '✅ 符合新朋友活動條件' : '❌ 不符合新朋友活動條件',
                    style: TextStyle(
                      color: meetsConditions ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRow(String label, String value, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            size: 16,
            color: isMet ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAllFieldsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '所有欄位',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._userData!.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
} 