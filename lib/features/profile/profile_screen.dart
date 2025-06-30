import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/core/providers/flag_status_provider.dart';
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
      };

      await _database.child('users/${user.uid}').set(data);

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
                        await flagStatusProvider.setFlagStatus(value);
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
