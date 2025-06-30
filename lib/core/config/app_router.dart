import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';
import 'package:auto30_next/features/auth/presentation/screens/login_screen.dart';
import 'package:auto30_next/features/home/presentation/screens/home_screen.dart';
import 'package:auto30_next/features/map/map_screen.dart';
import 'package:auto30_next/features/match/match_screen.dart';
import 'package:auto30_next/features/profile/profile_screen.dart';
import 'package:auto30_next/features/qr/presentation/screens/my_qr_screen.dart';
import 'package:auto30_next/features/social/presentation/screens/social_main_screen.dart';
import 'package:auto30_next/features/learning_center/presentation/screens/learning_center_screen.dart';
import 'package:auto30_next/features/profile/user_detail_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        
        // 🎯 允許未登入用戶訪問的公開頁面
        final publicPaths = [
          '/login',
          '/user/',     // 用戶詳細頁面
          '/flag/',     // 互助旗頁面
        ];
        
        // 檢查是否為公開路徑
        final isPublicPath = publicPaths.any((path) => 
          state.matchedLocation.startsWith(path));

        // 如果未登入且不在登入頁面且不是公開頁面，導向登入頁面
        if (!isAuthenticated && !isLoggingIn && !isPublicPath) {
          return '/login';
        }

        // 如果已登入且在登入頁面，導向首頁
        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        return null; // 不需要重導向
      },
      routes: [
        // 登入頁面
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // 首頁
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // 地圖頁面
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),

        // 配對頁面
        GoRoute(
          path: '/match',
          name: 'match',
          builder: (context, state) => const MatchScreen(),
        ),

        // 社群頁面
        GoRoute(
          path: '/social',
          name: 'social',
          builder: (context, state) => const SocialMainScreen(),
        ),

        // QR碼頁面
        GoRoute(
          path: '/qr',
          name: 'qr',
          builder: (context, state) => const MyQrScreen(),
        ),

        // 學習中心頁面
        GoRoute(
          path: '/learning',
          name: 'learning',
          builder: (context, state) => const LearningCenterScreen(),
        ),

        // 個人資料頁面
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // 地圖頁面 - 動態路由
        GoRoute(
          path: '/map_detail/:latlng',
          name: 'map_detail',
          builder: (context, state) {
            final latlng = state.pathParameters['latlng']!;
            return MapScreen(latlng: latlng);
          },
        ),

        // 用戶詳細頁面 - 動態路由
        GoRoute(
          path: '/user/:uid',
          name: 'userDetail',
          builder: (context, state) {
            final uid = state.pathParameters['uid']!;
            return UserDetailScreen(uid: uid);
          },
        ),

        // 互助旗頁面 - 動態路由
        GoRoute(
          path: '/flag/:uid',
          name: 'flag',
          builder: (context, state) {
            final uid = state.pathParameters['uid']!;
            return UserDetailScreen(uid: uid, showAsFlag: true);
          },
        ),
      ],
      
      // 錯誤頁面
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('頁面不存在')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('找不到頁面: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('回到首頁'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 