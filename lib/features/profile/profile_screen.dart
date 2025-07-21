import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/core/providers/flag_status_provider.dart';
import 'package:auto30_next/services/account_deletion_service.dart';
import 'location_picker_screen.dart';

// Helper function to safely parse coordinate values.
double _parseCoordinate(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return 0.0;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  
  // Controllers matching auto20-next data structure
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _connectMeController = TextEditingController();
  final _siteController = TextEditingController();
  final _site2Controller = TextEditingController();
  final _noteController = TextEditingController();
  final _priceController = TextEditingController();
  
  // 新增欄位控制器
  final _availableTimeController = TextEditingController(); // 比較有空的時段
  final _oldestChildBirthController = TextEditingController(); // 最大孩子的出生年次
  final _youngestChildBirthController = TextEditingController(); // 最小孩子的出生年次
  
  // Controllers for custom, user-entered text
  final _customHabitsController = TextEditingController();
  final _customSharesController = TextEditingController();
  final _customAsksController = TextEditingController();

  String? _selectedBirthYear;
  
  List<String> _selectedHabits = []; // learner_habit
  List<String> _selectedShares = []; // share
  List<String> _selectedAsks = [];   // ask

  // 新增選擇欄位
  String _selectedRole = '自學生'; // learner_role
  String _selectedLearningType = '類學校機構'; // learner_type

  // TODO: Implement map selection for latlng
  Map<String, double>? _latlng;

  bool _isLoading = true;
  
  // 帳號刪除服務
  final AccountDeletionService _deletionService = AccountDeletionService();
  
  final List<String> _availableHabits = [
    '程式設計', '數學', '物理', '化學', '生物', '歷史', '地理', '文學', '藝術', '音樂',
    '運動', '烹飪', '攝影', '繪畫', '書法', '語言學習', '天文', '園藝', '手工藝', '舞蹈'
  ];

  final List<String> _availableShares = [
    'Flutter開發', 'Python程式設計', '英文對話', '日文基礎', '數學輔導', '物理教學',
    '音樂演奏', '繪畫技巧', '烹飪技能', '攝影技術', '寫作能力', '演講技巧'
  ];
  
  final List<String> _availableAsks = [
    '尋求程式指導', '找人練習英文', '想學樂器', '一起運動', '專案合作', '討論學術主題'
  ];

  // 新增選項列表
  final List<String> _availableRoles = [
    '自學生', '家長', '教育工作者', '其他'
  ];

  final List<String> _availableLearningTypes = [
    '類學校機構', '完全自主學習', '混合式學習', '其他'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  List<String> _parseList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data.map((e) => e.toString()));
    if (data is String) return data.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return [];
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      final snapshot = await _database.child('users/${user.uid}').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        
        _nameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _connectMeController.text = data['connect_me'] ?? '';
        _siteController.text = data['site'] ?? '';
        _site2Controller.text = data['site2'] ?? '';
        _noteController.text = data['note'] ?? '';
        _priceController.text = data['price'] ?? '';

        // 載入新欄位
        _availableTimeController.text = data['available_time'] ?? '';
        _oldestChildBirthController.text = data['oldest_child_birth'] ?? '';
        _youngestChildBirthController.text = data['youngest_child_birth'] ?? '';
        _selectedRole = data['learner_role'] ?? '自學生';
        _selectedLearningType = data['learner_type'] ?? '類學校機構';

        if (data['learner_birth'] != null && data['learner_birth'].toString().isNotEmpty) {
          _selectedBirthYear = data['learner_birth'].toString();
        }
        
        _selectedHabits = _parseList(data['learner_habit']);
        _selectedShares = _parseList(data['share']);
        _selectedAsks = _parseList(data['ask']);

        // Separate pre-defined from custom for editing in text fields
        _customHabitsController.text = _selectedHabits.where((h) => !_availableHabits.contains(h)).join(', ');
        _customSharesController.text = _selectedShares.where((s) => !_availableShares.contains(s)).join(', ');
        _customAsksController.text = _selectedAsks.where((a) => !_availableAsks.contains(a)).join(', ');
        
        if (data['latlngColumn'] != null && data['latlngColumn'] is String) {
          final parts = data['latlngColumn'].split(',');
          if (parts.length == 2) {
            _latlng = {
              'lat': double.tryParse(parts[0]) ?? 0.0,
              'lng': double.tryParse(parts[1]) ?? 0.0,
            };
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已載入現有資料'), backgroundColor: Colors.green),
          );
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('沒有找到現有資料，請填寫新的互助旗'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      print('載入資料時發生錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料時發生錯誤：$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請檢查輸入的資料是否有誤'), backgroundColor: Colors.red),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請先登入')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Helper to combine selections from chips and custom text fields and convert to a string
      String getFinalString(List<String> selected, List<String> available, TextEditingController customController) {
        final fromChips = selected.where((s) => available.contains(s));
        final fromText = customController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        return {...fromChips, ...fromText}.toList().join(', ');
      }

      // 先讀取現有數據，保留重要欄位（如 flag_down）
      Map<String, dynamic>? existingData;
      try {
        final snapshot = await _database.child('users/${user.uid}').get();
        if (snapshot.exists && snapshot.value != null) {
          existingData = Map<String, dynamic>.from(snapshot.value as Map);
        }
      } catch (e) {
        print('讀取現有資料時發生錯誤: $e');
      }

      final latStr = _latlng != null ? '${_latlng!['lat']},${_latlng!['lng']}' : null;
      final data = {
        'name': _nameController.text,
        'address': _addressController.text,
        'connect_me': _connectMeController.text,
        'site': _siteController.text,
        'site2': _site2Controller.text,
        'note': _noteController.text,
        'price': _priceController.text,
        'learner_birth': _selectedBirthYear,
        'learner_habit': getFinalString(_selectedHabits, _availableHabits, _customHabitsController),
        'share': getFinalString(_selectedShares, _availableShares, _customSharesController),
        'ask': getFinalString(_selectedAsks, _availableAsks, _customAsksController),
        'latlngColumn': latStr,
        'lastUpdate': ServerValue.timestamp,
        'email': user.email,
        'uid': user.uid,
        'photoURL': user.photoURL,
        'learner_role': _selectedRole,
        'learner_type': _selectedLearningType,
        'available_time': _availableTimeController.text,
        'oldest_child_birth': _oldestChildBirthController.text,
        'youngest_child_birth': _youngestChildBirthController.text,
        
        // 🔧 保留重要的系統欄位，防止被刪除
        if (existingData != null) ...{
          if (existingData['flag_down'] != null) 'flag_down': existingData['flag_down'],
          if (existingData['last_flag_update'] != null) 'last_flag_update': existingData['last_flag_update'],
        },
      };

      // 使用 update() 而不是 set() 來避免刪除其他欄位
      await _database.child('users/${user.uid}').update(data);

      print('個人資料已保存，保留了 flag_down 相關欄位');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('互助旗已成功更新！'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('保存資料時發生錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存時發生錯誤：$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if(mounted) {
        setState(() => _isLoading = false);
      }
         }
   }

  /// 執行簡化版帳號刪除（跳過重新認證）
  Future<void> _executeSimpleAccountDeletion() async {
    // 顯示警告對話框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 簡化刪除'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('簡化刪除會：'),
            Text('✅ 清除你在資料庫中的所有資料'),
            Text('✅ 刪除配對記錄'),
            Text('✅ 清除本地儲存'),
            SizedBox(height: 8),
            Text('但可能無法：'),
            Text('❌ 完全刪除 Firebase 帳號'),
            SizedBox(height: 16),
            Text(
              '這意味著你的資料會被清除，但可能仍需要重新登入才能完全刪除帳號。',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('繼續簡化刪除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 顯示載入對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在執行簡化刪除...'),
            Text('清除資料中，請稍候'),
          ],
        ),
      ),
    );

    try {
      await _deletionService.deleteUserAccountSimple();
      
      if (mounted) {
        Navigator.of(context).pop(); // 關閉載入對話框
        
        // 顯示成功訊息
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✅ 資料清除成功'),
            content: const Text(
              '你的資料已經從系統中清除。\n\n'
              '如果需要完全刪除 Firebase 帳號，請重新登入後再次嘗試完整刪除。'
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('前往登入頁面'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 關閉載入對話框
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('簡化刪除失敗：$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的互助旗'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 互助旗狀態區塊
                    Consumer<FlagStatusProvider>(
                      builder: (context, flagStatusProvider, child) {
                        return _buildFlagStatusSection(flagStatusProvider);
                      },
                    ),
                    
                    _buildSectionTitle('基本資訊'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: '姓名/暱稱'),
                      validator: (value) => value!.isEmpty ? '請輸入姓名/暱稱' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _selectedBirthYear,
                      decoration: const InputDecoration(
                        labelText: '出生年（西元）',
                        hintText: '例如：2005',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return '請輸入出生年';
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year) return '請輸入正確的西元年';
                        return null;
                      },
                      onChanged: (value) => _selectedBirthYear = value,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: '所在地區'),
                       validator: (value) => value!.isEmpty ? '請輸入所在地區' : null,
                    ),
                    // Placeholder for map functionality
                    if (_latlng != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('座標: ${_latlng!['lat']!.toStringAsFixed(4)}, ${_latlng!['lng']!.toStringAsFixed(4)}'),
                      ),
                    ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push<LatLng?>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationPickerScreen(
                                  initialLocation: _latlng != null
                                      ? LatLng(_latlng!['lat']!, _latlng!['lng']!)
                                      : null),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              _latlng = {
                                'lat': result.latitude,
                                'lng': result.longitude,
                              };
                            });
                          }
                        },
                        child: const Text('在地圖上設定位置')),

                    _buildSectionTitle('聯絡與連結'),
                    TextFormField(
                      controller: _connectMeController,
                      decoration: const InputDecoration(labelText: '聯絡方式'),
                      validator: (value) => value!.isEmpty ? '請輸入聯絡方式' : null,
                    ),
                    const SizedBox(height: 12),
                     TextFormField(
                      controller: _siteController,
                      decoration: const InputDecoration(labelText: '個人網站/社群'),
                    ),
                    const SizedBox(height: 12),
                     TextFormField(
                      controller: _site2Controller,
                      decoration: const InputDecoration(labelText: '個人網站/社群 2'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _availableTimeController,
                      decoration: const InputDecoration(
                        labelText: '比較有空的時段',
                        hintText: '例如：週五下午和週末',
                      ),
                    ),

                    _buildSectionTitle('社交資訊'),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: '您的身份 *',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableRoles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                      validator: (value) => value == null ? '請選擇身份' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedLearningType,
                      decoration: const InputDecoration(
                        labelText: '主要的自學型態 *',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableLearningTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLearningType = newValue!;
                        });
                      },
                      validator: (value) => value == null ? '請選擇自學型態' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _oldestChildBirthController,
                      decoration: const InputDecoration(
                        labelText: '最大孩子的出生年次(西元)',
                        hintText: '若還沒有孩子或還不需找共學夥伴可略過',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _youngestChildBirthController,
                      decoration: const InputDecoration(
                        labelText: '最小孩子的出生年次(西元)',
                        hintText: '若您有多位孩子，請再填寫',
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    _buildSectionTitle('關於我'),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: '自我介紹 (note)'),
                      maxLines: 5,
                      validator: (value) => (value?.length ?? 0) < 20 ? '自我介紹至少需要20個字' : null,
                    ),

                    _buildSectionTitle('興趣 (learner_habit)'),
                    _buildChipSelector(_availableHabits, _selectedHabits, (selected) {
                      setState(() => _updateSelection(_selectedHabits, selected));
                    }),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customHabitsController,
                      decoration: const InputDecoration(
                        labelText: '其他興趣 (請用逗號,分隔)',
                        hintText: '例如: 哲學, 自主學習',
                      ),
                    ),

                    _buildSectionTitle('我能分享的 (share)'),
                     _buildChipSelector(_availableShares, _selectedShares, (selected) {
                      setState(() => _updateSelection(_selectedShares, selected));
                    }),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customSharesController,
                      decoration: const InputDecoration(
                        labelText: '其他分享 (請用逗號,分隔)',
                      ),
                    ),

                    _buildSectionTitle('我想學習的 (ask)'),
                     _buildChipSelector(_availableAsks, _selectedAsks, (selected) {
                      setState(() => _updateSelection(_selectedAsks, selected));
                    }),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customAsksController,
                      decoration: const InputDecoration(
                        labelText: '其他想學的 (請用逗號,分隔)',
                      ),
                    ),
                    
                    _buildSectionTitle('收費說明 (price)'),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: '例如：免費、NTD 500/hr 等'),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('保存互助旗'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 🗑️ 完整刪除互助旗和帳號按鈕
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showDeleteAccountDialog,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('完整刪除互助旗和帳號'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFlagStatusSection(FlagStatusProvider flagStatusProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  flagStatusProvider.statusIcon,
                  color: flagStatusProvider.statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '任務完成 降下互助旗',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        flagStatusProvider.statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (flagStatusProvider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: flagStatusProvider.isFlagDown,
                    activeColor: Colors.orange,
                    onChanged: (value) async {
                      try {
                        // 添加診斷信息
                        print('=== 個人資料頁面：切換互助旗狀態 ===');
                        print('目標狀態: $value');
                        await flagStatusProvider.printDiagnosis();
                        
                        await flagStatusProvider.setFlagStatus(value);
                        
                        // 切換完成後再次診斷
                        print('=== 個人資料頁面：切換完成後狀態 ===');
                        await flagStatusProvider.printDiagnosis();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value ? '互助旗已降下 - 你將不會出現在地圖和配對中' : '互助旗已升起 - 重新開始尋求協助',
                              ),
                              backgroundColor: value ? Colors.grey : Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        print('個人資料頁面：互助旗切換失敗: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('更新狀態失敗：$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 簡潔的說明文字
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: flagStatusProvider.isFlagDown 
                    ? Colors.grey.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: flagStatusProvider.isFlagDown 
                      ? Colors.grey.withOpacity(0.3) 
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: flagStatusProvider.statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flagStatusProvider.isFlagDown
                          ? '互助旗已降下 - 暫時隱藏，不會出現在地圖和配對中'
                          : '互助旗升起中 - 其他人可以看到你並與你配對',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.orange),
      ),
    );
  }
  
  void _updateSelection(List<String> list, String item) {
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
  }

  Widget _buildChipSelector(List<String> allOptions, List<String> selectedOptions, Function(String) onSelected) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: allOptions.map((option) {
        final isSelected = selectedOptions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool selected) => onSelected(option),
          selectedColor: Colors.orange.shade100,
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }


  /// 顯示刪除帳號確認對話框
  void _showDeleteAccountDialog() async {
    // 檢查用戶是否有權限刪除帳號
    final canDelete = await _deletionService.canDeleteAccount();
    if (!canDelete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('當前帳號無法執行刪除操作'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 檢查 Firebase 資料庫權限
    final permissions = await _deletionService.checkDatabasePermissions();
    debugPrint('Firebase 權限檢查結果: $permissions');

    // 先獲取要刪除的資料摘要
    final dataSummary = await _deletionService.getDataSummary();
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // 不能點外面關閉
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('⚠️ 危險操作'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '你即將完整刪除你的帳號和所有資料，這個操作無法復原！',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('📋 將會刪除的資料：'),
                const SizedBox(height: 8),
                
                // 顯示資料摘要
                if (dataSummary['userData'] != null) ...[
                  Text('👤 姓名：${dataSummary['userData']['name']}'),
                  Text('📧 信箱：${dataSummary['userData']['email']}'),
                  Text('📍 地區：${dataSummary['userData']['address']}'),
                  Text('🎭 身份：${dataSummary['userData']['learnerRole']}'),
                  Text('📅 註冊時間：${dataSummary['userData']['registrationDate']}'),
                ],
                Text('🤝 配對記錄：${dataSummary['matchCount']} 筆'),
                Text('🚩 互助旗狀態：${dataSummary['flagStatus']}'),
                Text('🔐 登入方式：${dataSummary['loginMethod']}'),
                                 Text('📆 帳號年齡：${dataSummary['accountAge']} 天'),
                 
                 const SizedBox(height: 16),
                 
                 // 顯示權限狀態
                 const Text(
                   '🔐 資料庫權限狀態：',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
                 Text('• 用戶資料：${permissions['userDataWrite'] == true ? "✅ 可刪除" : "❌ 權限不足"}'),
                 Text('• 配對記錄：${permissions['matchesWrite'] == true ? "✅ 可刪除" : "⚠️ 可能無法刪除"}'),
                 
                 const SizedBox(height: 16),
                 const Text(
                   '⚠️ 注意：刪除後你將無法：',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
                 const Text('• 登入這個帳號'),
                 const Text('• 恢復任何資料'),
                 const Text('• 查看過往的配對記錄'),
                 const Text('• 使用相同信箱重新註冊（可能需要等待）'),
                 
                 if (permissions['matchesWrite'] != true) ...[
                   const SizedBox(height: 16),
                   const Text(
                     '⚠️ 配對記錄權限不足：部分配對記錄可能無法刪除，但不影響主要資料清除。',
                     style: TextStyle(color: Colors.orange, fontSize: 12),
                   ),
                 ],
                
                if (dataSummary['error'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '⚠️ 讀取資料時發生錯誤：${dataSummary['error']}',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showFinalConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('我了解，繼續刪除'),
            ),
          ],
        );
      },
    );
  }

  /// 最終確認對話框
  void _showFinalConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🔒 最後確認'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '請再次確認你真的要刪除帳號。',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('這是最後一次機會可以取消！'),
              SizedBox(height: 16),
              Text(
                '⚠️ 刪除過程可能需要一些時間，請耐心等待。',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我反悔了，取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _executeAccountDeletion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('確定刪除帳號'),
            ),
          ],
        );
      },
    );
  }

  /// 執行帳號刪除
  Future<void> _executeAccountDeletion() async {
    // 顯示載入對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在刪除帳號...'),
            Text('請稍候，不要關閉應用程式'),
            SizedBox(height: 8),
            Text(
              '這個過程可能需要幾分鐘',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      await _deletionService.deleteUserAccount();
      
      if (mounted) {
        Navigator.of(context).pop(); // 關閉載入對話框
        
        // 顯示成功訊息
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✅ 刪除成功'),
            content: const Text(
              '你的帳號和所有資料已經完全刪除。\n\n'
              '感謝你使用 Auto30 Next，希望未來有機會再為你服務！'
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // 導航到登入頁面並清除所有路由歷史
                  context.go('/login');
                },
                child: const Text('確定'),
              ),
            ],
          ),
        );
      }
         } catch (e) {
       if (mounted) {
         Navigator.of(context).pop(); // 關閉載入對話框
         
         // 特殊處理認證相關錯誤
         final errorMessage = e.toString();
         bool isAuthError = errorMessage.contains('Google 重新認證') || 
                           errorMessage.contains('requires-recent-login') ||
                           errorMessage.contains('ClientID not set');
         
         // 顯示錯誤訊息
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: Text(isAuthError ? '🔐 認證問題' : '❌ 刪除失敗'),
             content: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(isAuthError ? '刪除帳號時遇到認證問題：' : '刪除帳號時發生錯誤：'),
                 const SizedBox(height: 8),
                 Text(
                   errorMessage,
                   style: const TextStyle(color: Colors.red, fontSize: 12),
                 ),
                 const SizedBox(height: 16),
                 Text(isAuthError ? '建議的解決方案：' : '可能的解決方案：'),
                 if (isAuthError) ...[
                   const Text('• 重新登出並重新登入'),
                   const Text('• 確認 Google 帳號狀態正常'),
                   const Text('• 稍後再試'),
                 ] else ...[
                   const Text('• 檢查網路連線'),
                   const Text('• 重新登入後再試'),
                   const Text('• 聯絡客服協助'),
                 ],
                 if (isAuthError) ...[
                   const SizedBox(height: 16),
                   const Text(
                     '注意：即使認證失敗，你的資料可能已經部分清除。',
                     style: TextStyle(
                       color: Colors.orange,
                       fontSize: 12,
                     ),
                   ),
                 ],
               ],
             ),
             actions: [
                                if (isAuthError) ...[
                   TextButton(
                     onPressed: () {
                       Navigator.of(context).pop();
                       // 導航到登入頁面
                       context.go('/login');
                     },
                     child: const Text('重新登入'),
                   ),
                   TextButton(
                     onPressed: () {
                       Navigator.of(context).pop();
                       _executeSimpleAccountDeletion();
                     },
                     style: TextButton.styleFrom(
                       foregroundColor: Colors.orange,
                     ),
                     child: const Text('嘗試簡化刪除'),
                   ),
                 ],
               TextButton(
                 onPressed: () => Navigator.of(context).pop(),
                 child: const Text('確定'),
               ),
             ],
           ),
         );
       }
     }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _connectMeController.dispose();
    _siteController.dispose();
    _site2Controller.dispose();
    _noteController.dispose();
    _priceController.dispose();
    _customHabitsController.dispose();
    _customSharesController.dispose();
    _customAsksController.dispose();
    _availableTimeController.dispose();
    _oldestChildBirthController.dispose();
    _youngestChildBirthController.dispose();
    super.dispose();
  }
}
