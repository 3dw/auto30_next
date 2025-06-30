import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/core/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 主題設定區塊
              _buildSectionHeader('外觀設定'),
              _buildThemeCard(context, themeProvider),
              
              const SizedBox(height: 24),
              
              // 其他設定區塊
              _buildSectionHeader('其他設定'),
              _buildSettingsCard(
                context,
                title: '通知設定',
                subtitle: '管理推播通知偏好',
                icon: Icons.notifications,
                onTap: () {
                  // TODO: 導向通知設定頁面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知設定功能開發中')),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              _buildSettingsCard(
                context,
                title: '隱私設定',
                subtitle: '管理個人資料可見性',
                icon: Icons.privacy_tip,
                onTap: () {
                  // TODO: 導向隱私設定頁面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('隱私設定功能開發中')),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              _buildSettingsCard(
                context,
                title: '關於應用程式',
                subtitle: '版本資訊和開發團隊',
                icon: Icons.info,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(themeProvider.themeModeIcon, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '主題模式',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '目前：${themeProvider.themeModeText}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => themeProvider.toggleThemeMode(),
                  icon: const Icon(Icons.refresh),
                  tooltip: '切換主題',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 主題選項
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context,
                    title: '跟隨系統',
                    icon: Icons.brightness_auto,
                    isSelected: themeProvider.isSystemMode,
                    onTap: () => themeProvider.setSystemMode(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    title: '白天模式',
                    icon: Icons.light_mode,
                    isSelected: themeProvider.themeMode == ThemeMode.light,
                    onTap: () => themeProvider.setLightMode(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    title: '黑夜模式',
                    icon: Icons.dark_mode,
                    isSelected: themeProvider.themeMode == ThemeMode.dark,
                    onTap: () => themeProvider.setDarkMode(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.orange : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Auto30 Next',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.school,
        size: 48,
        color: Colors.orange,
      ),
      children: [
        const Text('一個專為自學者設計的互助學習平台'),
        const SizedBox(height: 16),
        const Text('開發團隊：'),
        const Text('• 前端開發：Flutter'),
        const Text('• 後端服務：Firebase'),
        const Text('• 地圖服務：OpenStreetMap'),
      ],
    );
  }
} 