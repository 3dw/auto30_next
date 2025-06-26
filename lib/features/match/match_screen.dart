import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:auto30_next/features/profile/user_detail_screen.dart';

class UserModel {
  final String id;
  final String name;
  final String learnerBirth; // 西元年
  final String address;
  final LatLng location;
  final List<String> habits; // 興趣
  final List<String> share;  // 可分享
  final List<String> ask;    // 想學習

  UserModel({
    required this.id,
    required this.name,
    required this.learnerBirth,
    required this.address,
    required this.location,
    required this.habits,
    required this.share,
    required this.ask,
  });

  factory UserModel.fromFirebase(String id, Map<String, dynamic> data) {
    // 解析 latlngColumn 格式 "25.20044,121.43399"
    LatLng location = const LatLng(0, 0);
    if (data['latlngColumn'] != null && data['latlngColumn'] is String) {
      final parts = data['latlngColumn'].split(',');
      if (parts.length == 2) {
        location = LatLng(
          double.tryParse(parts[0]) ?? 0.0,
          double.tryParse(parts[1]) ?? 0.0,
        );
      }
    }
    List<String> parseList(dynamic v) {
      if (v == null) return [];
      if (v is List) return List<String>.from(v.map((e) => e.toString()));
      if (v is String) return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return [];
    }

    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown User',
      learnerBirth: data['learner_birth']?.toString() ?? '2000',
      address: data['address'] ?? '',
      location: location,
      habits: parseList(data['learner_habit']),
      share: parseList(data['share']),
      ask: parseList(data['ask']),
    );
  }
}

int interestScore(List<String> myHabits, List<String> otherHabits) {
  return myHabits.toSet().intersection(otherHabits.toSet()).length;
}

double geoDistance(LatLng a, LatLng b) {
  const earthRadius = 6371.0;
  final dLat = (b.latitude - a.latitude) * (pi / 180.0);
  final dLng = (b.longitude - a.longitude) * (pi / 180.0);
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(a.latitude * (pi / 180.0)) *
          cos(b.latitude * (pi / 180.0)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  return earthRadius * 2 * atan2(sqrt(h), sqrt(1 - h));
}

int skillScore(List<String> myAsk, List<String> otherShare, List<String> myShare, List<String> otherAsk) {
  int score = 0;
  if (myAsk.toSet().intersection(otherShare.toSet()).isNotEmpty) score += 1;
  if (myShare.toSet().intersection(otherAsk.toSet()).isNotEmpty) score += 1;
  return score;
}

List<UserModel> matchByInterest(UserModel me, List<UserModel> all) {
  return all
      .where((u) => u.id != me.id)
      .toList()
    ..sort((a, b) =>
        interestScore(me.habits, b.habits).compareTo(interestScore(me.habits, a.habits)));
}

List<UserModel> matchByLocation(UserModel me, List<UserModel> all) {
  return all
      .where((u) => u.id != me.id)
      .toList()
    ..sort((a, b) =>
        geoDistance(me.location, a.location).compareTo(geoDistance(me.location, b.location)));
}

List<UserModel> matchBySkill(UserModel me, List<UserModel> all) {
  return all
      .where((u) => u.id != me.id)
      .toList()
    ..sort((a, b) =>
        skillScore(me.ask, b.share, me.share, b.ask).compareTo(skillScore(me.ask, a.share, me.share, a.ask)));
}

List<UserModel> matchRandom(UserModel me, List<UserModel> all) {
  final others = all.where((u) => u.id != me.id).toList();
  others.shuffle();
  return others;
}

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int modeIndex = 0; // 0:興趣 1:位置 2:技能 3:隨機
  List<UserModel> allUsers = [];
  UserModel? currentUser;
  List<UserModel> candidates = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final users = <UserModel>[];
      for (final entry in data.entries) {
        users.add(UserModel.fromFirebase(entry.key, Map<String, dynamic>.from(entry.value)));
      }
      allUsers = users;
      currentUser = users.firstWhere((u) => u.id == user.uid, orElse: () => users.first);
      _refreshCandidates();
    }
    setState(() => isLoading = false);
  }

  void _refreshCandidates() {
    if (currentUser == null) return;
    switch (modeIndex) {
      case 0:
        candidates = matchByInterest(currentUser!, allUsers);
        break;
      case 1:
        candidates = matchByLocation(currentUser!, allUsers);
        break;
      case 2:
        candidates = matchBySkill(currentUser!, allUsers);
        break;
      case 3:
        candidates = matchRandom(currentUser!, allUsers);
        break;
    }
    currentIndex = 0;
    setState(() {});
  }

  Future<void> saveMatchRecord(String myUid, String otherUid, String matchType, int score) async {
    final ref = FirebaseDatabase.instance.ref('matches/$myUid/$otherUid');
    await ref.set({
      'matchType': matchType,
      'score': score,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    final modeNames = ['興趣配對', '位置配對', '技能配對', '隨機配對'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能配對'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 配對模式切換
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(modeNames.length, (i) {
                    return ChoiceChip(
                      label: Text(modeNames[i]),
                      selected: modeIndex == i,
                      onSelected: (selected) {
                        if (selected) {
                          modeIndex = i;
                          _refreshCandidates();
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // 配對卡片
                if (candidates.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: _UserCard(
                        user: candidates[currentIndex],
                        matchScore: _getMatchScore(currentUser!, candidates[currentIndex], modeIndex),
                        matchType: modeNames[modeIndex],
                        onLike: () async {
                          final myUid = FirebaseAuth.instance.currentUser?.uid;
                          if (myUid != null) {
                            await saveMatchRecord(myUid, candidates[currentIndex].id, modeNames[modeIndex], _getMatchScore(currentUser!, candidates[currentIndex], modeIndex));
                          }
                          setState(() {
                            if (currentIndex < candidates.length - 1) currentIndex++;
                          });
                        },
                        onDislike: () {
                          setState(() {
                            if (currentIndex < candidates.length - 1) currentIndex++;
                          });
                        },
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied, color: Colors.orange, size: 48),
                          SizedBox(height: 12),
                          Text('目前沒有推薦用戶', style: TextStyle(fontSize: 18, color: Colors.orange)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  int _getMatchScore(UserModel me, UserModel other, int mode) {
    switch (mode) {
      case 0:
        return interestScore(me.habits, other.habits);
      case 1:
        final d = geoDistance(me.location, other.location);
        return (d > 9999) ? 0 : (100 - d.round()).clamp(0, 100); // 距離越近分數越高
      case 2:
        return skillScore(me.ask, other.share, me.share, other.ask) * 50;
      default:
        return 0;
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final int matchScore;
  final String matchType;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  const _UserCard({
    required this.user,
    required this.matchScore,
    required this.matchType,
    required this.onLike,
    required this.onDislike,
  });

  String getAgeText(String learnerBirth) {
    try {
      final year = int.tryParse(learnerBirth.substring(0, 4));
      if (year != null) {
        final age = DateTime.now().year - year;
        return '年齡：約$age 歲';
      }
    } catch (_) {}
    return '年齡：未知';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 頭像
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.orange.shade100,
              child: Text(user.name.isNotEmpty ? user.name[0] : '?',
                  style: const TextStyle(fontSize: 36, color: Colors.orange)),
            ),
            const SizedBox(height: 12),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(getAgeText(user.learnerBirth)),
            Text('地區：${user.address}'),
            const Divider(height: 24),
            Text('興趣：${user.habits.join(", ")}'),
            Text('可分享：${user.share.join(", ")}'),
            Text('想學習：${user.ask.join(", ")}'),
            const SizedBox(height: 12),
            // 配對分數
            if (matchScore >= 0)
              Chip(
                label: Text('$matchType配對分數：$matchScore',
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.orange,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  onPressed: onDislike,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: onLike,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.favorite),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});
  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Map<String, dynamic>> records = [];
  Map<String, dynamic> userMap = {}; // uid -> user簡單資料
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        errorMsg = '尚未登入，無法讀取配對紀錄';
        isLoading = false;
      });
      debugPrint('MatchHistory: user not logged in');
      return;
    }
    try {
      final ref = FirebaseDatabase.instance.ref('matches/${user.uid}');
      final snapshot = await ref.get();
      debugPrint('MatchHistory: snapshot.exists=${snapshot.exists}');
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final uids = data.keys.toList();
        // 讀取所有配對對象的簡單資料
        final usersRef = FirebaseDatabase.instance.ref('users');
        final usersSnap = await usersRef.get();
        Map<String, dynamic> userMapTmp = {};
        if (usersSnap.exists && usersSnap.value != null) {
          final allUsers = Map<String, dynamic>.from(usersSnap.value as Map);
          for (final uid in uids) {
            if (allUsers[uid] != null) {
              final u = Map<String, dynamic>.from(allUsers[uid]);
              userMapTmp[uid] = {
                'name': u['name'] ?? '',
                'address': u['address'] ?? '',
                'photoURL': u['photoURL'] ?? '',
              };
            }
          }
        }
        setState(() {
          records = data.entries.map((e) {
            final v = Map<String, dynamic>.from(e.value);
            v['uid'] = e.key;
            return v;
          }).toList();
          userMap = userMapTmp;
          isLoading = false;
          errorMsg = null;
        });
        debugPrint('MatchHistory: loaded ${records.length} records');
      } else {
        setState(() {
          records = [];
          isLoading = false;
          errorMsg = null;
        });
        debugPrint('MatchHistory: no records');
      }
    } catch (e) {
      setState(() {
        errorMsg = '讀取配對紀錄時發生錯誤：$e';
        isLoading = false;
      });
      debugPrint('MatchHistory: error $e');
    }
  }

  Future<void> _deleteRecord(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('matches/${user.uid}/$uid');
    await ref.remove();
    setState(() {
      records.removeWhere((r) => r['uid'] == uid);
      userMap.remove(uid);
    });
    debugPrint('MatchHistory: deleted record $uid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配對紀錄')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(
                  child: Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 18)),
                )
              : records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.info_outline, color: Colors.orange, size: 48),
                          SizedBox(height: 12),
                          Text('目前沒有配對紀錄', style: TextStyle(fontSize: 18, color: Colors.orange)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final r = records[i];
                        final uid = r['uid'];
                        final u = userMap[uid] ?? {};
                        return ListTile(
                          leading: u['photoURL'] != null && u['photoURL'].toString().isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(u['photoURL']))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(u['name']?.isNotEmpty == true ? u['name'] : '用戶ID: $uid'),
                          subtitle: Text(
                            '${r['matchType']}分數: ${r['score']}\n${u['address'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(r['timestamp']).toLocal(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: '刪除紀錄',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('刪除配對紀錄'),
                                      content: const Text('確定要刪除此配對紀錄嗎？'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('刪除')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteRecord(uid);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetailScreen(uid: uid),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
