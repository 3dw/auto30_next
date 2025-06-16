import 'package:flutter/material.dart';
import 'package:auto30_next/features/home/presentation/screens/home_screen.dart';
import 'package:auto30_next/features/map/map_screen.dart';
import 'package:auto30_next/features/match/match_screen.dart';
import 'package:auto30_next/features/profile/profile_screen.dart';

class SocialMainScreen extends StatefulWidget {
  const SocialMainScreen({super.key});

  @override
  State<SocialMainScreen> createState() => _SocialMainScreenState();
}

class _SocialMainScreenState extends State<SocialMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomeScreen(),
    MapScreen(),
    MatchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '地圖'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '配對'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '個人'),
        ],
      ),
    );
  }
} 