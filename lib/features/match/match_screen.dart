import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  Widget build(BuildContext context) {
    final modeNames = ['興趣配對', '位置配對', '技能配對', '隨機配對'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能配對'),
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
                        onLike: () {
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
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  const _UserCard({required this.user, required this.onLike, required this.onDislike});

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
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(getAgeText(user.learnerBirth)),
            Text('地區：${user.address}'),
            Text('興趣：${user.habits.join(", ")}'),
            Text('可分享：${user.share.join(", ")}'),
            Text('想學習：${user.ask.join(", ")}'),
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
