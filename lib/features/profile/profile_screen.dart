import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  List<String> _selectedInterests = [];
  List<String> _selectedSkills = [];
  bool _isPublic = true;
  bool _showLocation = true;
  bool _allowMessages = true;
  bool _isLoading = false;
  
  final List<String> _availableInterests = [
    '程式設計', '數學', '物理', '化學', '生物', '歷史', '地理', '文學', '藝術', '音樂',
    '運動', '烹飪', '攝影', '繪畫', '書法', '語言學習', '天文', '園藝', '手工藝', '舞蹈'
  ];

  final List<String> _availableSkills = [
    'Flutter開發', 'Python程式設計', '英文對話', '日文基礎', '數學輔導', '物理教學',
    '音樂演奏', '繪畫技巧', '烹飪技能', '攝影技術', '寫作能力', '演講技巧'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('ProfileScreen: 用戶未登入');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      print('ProfileScreen: 開始載入用戶資料，UID: ${user.uid}');
      
      // 嘗試多個可能的資料路徑
      final paths = [
        'users/${user.uid}/profile',
        'users/${user.uid}',
        'profiles/${user.uid}',
      ];
      
      Map<String, dynamic>? userData;
      String? usedPath;
      
      for (final path in paths) {
        try {
          print('ProfileScreen: 嘗試路徑: $path');
          final snapshot = await _database.child(path).get();
          
          if (snapshot.exists) {
            print('ProfileScreen: 在路徑 $path 找到資料');
            userData = Map<String, dynamic>.from(snapshot.value as Map);
            usedPath = path;
            break;
          } else {
            print('ProfileScreen: 路徑 $path 沒有資料');
          }
        } catch (e) {
          print('ProfileScreen: 路徑 $path 讀取失敗: $e');
        }
      }
      
      if (userData != null) {
        print('ProfileScreen: 成功載入資料: $userData');
        
        // 處理不同的資料結構
        Map<String, dynamic> profileData;
        if (userData.containsKey('profile')) {
          profileData = Map<String, dynamic>.from(userData['profile'] as Map);
        } else {
          profileData = userData;
        }
        
        setState(() {
          _nameController.text = profileData['name']?.toString() ?? '';
          _ageController.text = profileData['age']?.toString() ?? '';
          _bioController.text = profileData['bio']?.toString() ?? '';
          _locationController.text = profileData['location']?.toString() ?? '';
          
          // 處理興趣和技能列表
          if (profileData['interests'] != null) {
            if (profileData['interests'] is List) {
              _selectedInterests = List<String>.from(profileData['interests'] as List);
            } else if (profileData['interests'] is String) {
              _selectedInterests = [profileData['interests'] as String];
            }
          }
          
          if (profileData['skills'] != null) {
            if (profileData['skills'] is List) {
              _selectedSkills = List<String>.from(profileData['skills'] as List);
            } else if (profileData['skills'] is String) {
              _selectedSkills = [profileData['skills'] as String];
            }
          }
          
          _isPublic = profileData['isPublic'] ?? true;
          _showLocation = profileData['showLocation'] ?? true;
          _allowMessages = profileData['allowMessages'] ?? true;
        });
        
        print('ProfileScreen: 資料已載入到 UI');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已載入現有資料 (路徑: $usedPath)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('ProfileScreen: 沒有找到任何用戶資料');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('沒有找到現有資料，請填寫新的互助旗'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('ProfileScreen: 載入資料時發生錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('載入資料時發生錯誤：$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請先登入'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('ProfileScreen: 開始保存用戶資料，UID: ${user.uid}');
      
      final data = {
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'bio': _bioController.text,
        'location': _locationController.text,
        'interests': _selectedInterests,
        'skills': _selectedSkills,
        'isPublic': _isPublic,
        'showLocation': _showLocation,
        'allowMessages': _allowMessages,
        'lastUpdated': ServerValue.timestamp,
        'email': user.email,
        'uid': user.uid,
      };

      print('ProfileScreen: 準備保存的資料: $data');

      // 保存到主要路徑
      await _database.child('users/${user.uid}/profile').set(data);
      print('ProfileScreen: 資料已保存到 users/${user.uid}/profile');

      // 同時保存到根路徑作為備份
      await _database.child('users/${user.uid}').update({
        'profile': data,
        'lastUpdated': ServerValue.timestamp,
      });
      print('ProfileScreen: 備份資料已保存到 users/${user.uid}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('互助旗已成功更新！'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('ProfileScreen: 保存資料時發生錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存時發生錯誤：$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        title: const Text(
          '我的互助旗',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadUserData,
              tooltip: '重新載入資料',
            ),
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading && _nameController.text.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('載入中...', style: TextStyle(color: Colors.orange)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 個人資訊區域
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
                            const Icon(Icons.person, color: Colors.orange),
                            SizedBox(width: isDesktop ? 12 : 8),
                            Text(
                              '基本資訊',
                              style: TextStyle(
                                fontSize: isDesktop ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        
                        // 頭像
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: isDesktop ? 60 : 50,
                                backgroundColor: Colors.orange.shade100,
                                child: Icon(
                                  Icons.person,
                                  size: isDesktop ? 70 : 60,
                                  color: Colors.orange,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: isDesktop ? 20 : 16,
                                  backgroundColor: Colors.orange,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: isDesktop ? 20 : 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('更換頭像功能開發中')),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isDesktop ? 24 : 16),
                        
                        // 姓名和年齡
                        if (isDesktop) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: '姓名/暱稱',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge, color: Colors.orange),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _ageController,
                                  decoration: const InputDecoration(
                                    labelText: '年齡',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.cake, color: Colors.orange),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '姓名/暱稱',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge, color: Colors.orange),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: '年齡',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake, color: Colors.orange),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: '所在地區',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on, color: Colors.orange),
                            hintText: '例如：台北市大安區',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 個人介紹
                  SectionTitle(
                    title: '個人介紹', 
                    icon: Icons.description,
                    isDesktop: isDesktop,
                  ),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: '自我介紹',
                      border: OutlineInputBorder(),
                      hintText: '分享一下你的學習目標和興趣...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 興趣領域
                  SectionTitle(
                    title: '興趣領域', 
                    icon: Icons.interests,
                    isDesktop: isDesktop,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: isDesktop ? 12 : 8,
                      runSpacing: isDesktop ? 12 : 8,
                      children: _availableInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(interest);
                        return FilterChip(
                          label: Text(
                            interest,
                            style: TextStyle(fontSize: isDesktop ? 14 : 12),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInterests.add(interest);
                              } else {
                                _selectedInterests.remove(interest);
                              }
                            });
                          },
                          selectedColor: Colors.orange.shade100,
                          checkmarkColor: Colors.orange,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 專長技能
                  SectionTitle(
                    title: '專長技能', 
                    icon: Icons.star,
                    isDesktop: isDesktop,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepOrange.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: isDesktop ? 12 : 8,
                      runSpacing: isDesktop ? 12 : 8,
                      children: _availableSkills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(
                            skill,
                            style: TextStyle(fontSize: isDesktop ? 14 : 12),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                          selectedColor: Colors.deepOrange.shade100,
                          checkmarkColor: Colors.deepOrange,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 隱私設定
                  SectionTitle(
                    title: '隱私設定', 
                    icon: Icons.privacy_tip,
                    isDesktop: isDesktop,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              '公開我的互助旗',
                              style: TextStyle(fontSize: isDesktop ? 16 : 14),
                            ),
                            subtitle: Text(
                              '其他用戶可以看到我的資料',
                              style: TextStyle(fontSize: isDesktop ? 14 : 12),
                            ),
                            value: _isPublic,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                              });
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.orange),
                            title: Text(
                              '位置分享',
                              style: TextStyle(fontSize: isDesktop ? 16 : 14),
                            ),
                            subtitle: Text(
                              '允許顯示大概位置',
                              style: TextStyle(fontSize: isDesktop ? 14 : 12),
                            ),
                            trailing: Switch(
                              value: _showLocation,
                              activeColor: Colors.orange,
                              onChanged: (value) {
                                setState(() {
                                  _showLocation = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.message, color: Colors.orange),
                            title: Text(
                              '接收訊息',
                              style: TextStyle(fontSize: isDesktop ? 16 : 14),
                            ),
                            subtitle: Text(
                              '允許其他用戶聯繫我',
                              style: TextStyle(fontSize: isDesktop ? 14 : 12),
                            ),
                            trailing: Switch(
                              value: _allowMessages,
                              activeColor: Colors.orange,
                              onChanged: (value) {
                                setState(() {
                                  _allowMessages = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 互助旗預覽
                  SectionTitle(
                    title: '互助旗預覽', 
                    icon: Icons.preview,
                    isDesktop: isDesktop,
                  ),
                  UserFlagPreview(
                    name: _nameController.text.isNotEmpty ? _nameController.text : '學習者',
                    age: _ageController.text.isNotEmpty ? _ageController.text : '16',
                    bio: _bioController.text.isNotEmpty ? _bioController.text : '還沒有自我介紹',
                    interests: _selectedInterests,
                    skills: _selectedSkills,
                    isPublic: _isPublic,
                    isDesktop: isDesktop,
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                  
                  // 保存按鈕
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: Text(
                        '保存互助旗',
                        style: TextStyle(fontSize: isDesktop ? 18 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 32 : 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDesktop;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: isDesktop ? 24 : 20),
          SizedBox(width: isDesktop ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class UserFlagPreview extends StatelessWidget {
  final String name;
  final String age;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final bool isPublic;
  final bool isDesktop;

  const UserFlagPreview({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
    required this.interests,
    required this.skills,
    required this.isPublic,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isDesktop ? 35 : 25,
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(
                    Icons.person, 
                    color: Colors.orange,
                    size: isDesktop ? 40 : 30,
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
                          fontSize: isDesktop ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$age 歲',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isDesktop ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12 : 8, 
                    vertical: isDesktop ? 6 : 4
                  ),
                  decoration: BoxDecoration(
                    color: isPublic ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPublic ? '公開' : '私人',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              bio,
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            if (interests.isNotEmpty) ...[
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                '興趣愛好',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Wrap(
                spacing: isDesktop ? 8 : 6,
                runSpacing: isDesktop ? 8 : 6,
                children: interests.map((interest) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 10 : 8, 
                      vertical: isDesktop ? 6 : 4
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.orange,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (skills.isNotEmpty) ...[
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                '專長技能',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Wrap(
                spacing: isDesktop ? 8 : 6,
                runSpacing: isDesktop ? 8 : 6,
                children: skills.map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 10 : 8, 
                      vertical: isDesktop ? 6 : 4
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.deepOrange,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
