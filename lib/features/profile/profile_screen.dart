import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
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
  
  // Controllers for custom, user-entered text
  final _customHabitsController = TextEditingController();
  final _customSharesController = TextEditingController();
  final _customAsksController = TextEditingController();

  DateTime? _selectedBirthDate;
  
  List<String> _selectedHabits = []; // learner_habit
  List<String> _selectedShares = []; // share
  List<String> _selectedAsks = [];   // ask

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

        if (data['learner_birth'] != null && data['learner_birth'].toString().isNotEmpty) {
          try {
            _selectedBirthDate = DateTime.parse(data['learner_birth']);
          } catch(e) {
            print("Could not parse learner_birth: ${data['learner_birth']}");
          }
        }
        
        _selectedHabits = _parseList(data['learner_habit']);
        _selectedShares = _parseList(data['share']);
        _selectedAsks = _parseList(data['ask']);

        // Separate pre-defined from custom for editing in text fields
        _customHabitsController.text = _selectedHabits.where((h) => !_availableHabits.contains(h)).join(', ');
        _customSharesController.text = _selectedShares.where((s) => !_availableShares.contains(s)).join(', ');
        _customAsksController.text = _selectedAsks.where((a) => !_availableAsks.contains(a)).join(', ');
        
        if (data['latlngColumn'] != null && data['latlngColumn']['lat'] != null && data['latlngColumn']['lng'] != null) {
          _latlng = {
            'lat': _parseCoordinate(data['latlngColumn']['lat']),
            'lng': _parseCoordinate(data['latlngColumn']['lng']),
          };
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

      final data = {
        'name': _nameController.text,
        'address': _addressController.text,
        'connect_me': _connectMeController.text,
        'site': _siteController.text,
        'site2': _site2Controller.text,
        'note': _noteController.text,
        'price': _priceController.text,
        'learner_birth': _selectedBirthDate != null ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!) : null,
        'learner_habit': getFinalString(_selectedHabits, _availableHabits, _customHabitsController),
        'share': getFinalString(_selectedShares, _availableShares, _customSharesController),
        'ask': getFinalString(_selectedAsks, _availableAsks, _customAsksController),
        'latlngColumn': _latlng != null ? { 'lat': _latlng!['lat'], 'lng': _latlng!['lng'] } : null,
        'lastUpdate': ServerValue.timestamp,
        'email': user.email,
        'uid': user.uid,
        'photoURL': user.photoURL,
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

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
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
                    _buildSectionTitle('基本資訊'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: '姓名/暱稱'),
                      validator: (value) => value!.isEmpty ? '請輸入姓名/暱稱' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectBirthDate(context),
                      decoration: InputDecoration(
                        labelText: '出生年月日',
                        hintText: _selectedBirthDate == null 
                            ? '請選擇日期' 
                            : DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
                      ),
                       validator: (value) => _selectedBirthDate == null ? '請選擇出生年月日' : null,
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
    super.dispose();
  }
}
