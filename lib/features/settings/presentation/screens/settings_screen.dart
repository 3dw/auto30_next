import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto30_next/core/providers/theme_provider.dart';
import 'package:auto30_next/core/providers/flag_status_provider.dart';
import 'package:auto30_next/utils/firebase_test.dart';

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
      body: Consumer2<ThemeProvider, FlagStatusProvider>(
        builder: (context, themeProvider, flagStatusProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 主題設定區塊
              _buildSectionHeader('外觀設定'),
              _buildThemeCard(context, themeProvider),
              
              const SizedBox(height: 24),
              
              // 互助旗狀態設定區塊
              _buildSectionHeader('互助旗狀態'),
              _buildFlagStatusCard(context, flagStatusProvider),
              
              // 診斷按鈕（開發用）
              const SizedBox(height: 8),
              _buildDiagnosticCard(context, flagStatusProvider),
              
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

  Widget _buildFlagStatusCard(BuildContext context, FlagStatusProvider flagStatusProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  flagStatusProvider.statusIcon, 
                  color: flagStatusProvider.statusColor
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
                        print('=== 開始切換互助旗狀態 ===');
                        print('目標狀態: $value');
                        await flagStatusProvider.printDiagnosis();
                        
                        await flagStatusProvider.setFlagStatus(value);
                        
                        // 切換完成後再次診斷
                        print('=== 切換完成後狀態 ===');
                        await flagStatusProvider.printDiagnosis();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value ? '互助旗已降下 - 你將不會出現在地圖和配對中' : '互助旗已升起 - 重新開始尋求協助',
                              ),
                              backgroundColor: value ? Colors.grey : Colors.orange,
                              action: SnackBarAction(
                                label: '診斷',
                                textColor: Colors.white,
                                onPressed: () async {
                                  await flagStatusProvider.printDiagnosis();
                                },
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('互助旗切換失敗: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('更新狀態失敗：$e'),
                              backgroundColor: Colors.red,
                              action: SnackBarAction(
                                label: '查看詳情',
                                textColor: Colors.white,
                                onPressed: () {
                                  _showErrorDialog(context, e.toString());
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 說明文字
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: flagStatusProvider.isFlagDown 
                    ? Colors.grey.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: flagStatusProvider.isFlagDown 
                      ? Colors.grey.withOpacity(0.3) 
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: flagStatusProvider.statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        flagStatusProvider.isFlagDown ? '互助旗已降下' : '互助旗升起中',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: flagStatusProvider.statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flagStatusProvider.isFlagDown
                        ? '• 你不會出現在「附近的人」地圖中\n• 其他人無法與你配對\n• 你也無法主動配對其他人\n• 適合任務完成或暫時不需要協助時使用'
                        : '• 你會出現在「附近的人」地圖中\n• 其他人可以與你配對\n• 你可以主動配對其他人\n• 適合正在尋求學習協助時使用',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
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

  Widget _buildDiagnosticCard(BuildContext context, FlagStatusProvider flagStatusProvider) {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '診斷工具',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '如果互助旗功能有問題，可以使用以下工具進行診斷：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await flagStatusProvider.printDiagnosis();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('診斷信息已輸出到控制台'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('打印診斷'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final diagnosis = await flagStatusProvider.diagnose();
                      if (context.mounted) {
                        _showDiagnosisDialog(context, diagnosis);
                      }
                    },
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('顯示診斷'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('正在執行 Firebase 完整測試...'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    
                    final testResult = await FirebaseTest.fullTest();
                    FirebaseTest.printTestResult(testResult);
                    
                    if (context.mounted) {
                      _showFirebaseTestDialog(context, testResult);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('測試執行失敗：$e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.science, size: 16),
                label: const Text('Firebase 完整測試'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnosisDialog(BuildContext context, Map<String, dynamic> diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('系統診斷結果'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: diagnosis.entries.map((entry) {
                Color textColor = Colors.black87;
                if (entry.key.contains('Error') || entry.value == false) {
                  textColor = Colors.red;
                } else if (entry.value == true) {
                  textColor = Colors.green;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: '${entry.value}',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<FlagStatusProvider>().refresh();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已重新載入狀態'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('重新載入'),
          ),
        ],
      ),
    );
  }

  void _showFirebaseTestDialog(BuildContext context, Map<String, dynamic> testResult) {
    final health = testResult['overall_health'] as String;
    final suggestions = FirebaseTest.getFixSuggestions(health);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              health == 'HEALTHY' ? Icons.check_circle : Icons.error,
              color: health == 'HEALTHY' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Firebase 測試結果'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 健康狀態
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: health == 'HEALTHY' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: health == 'HEALTHY' ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        health == 'HEALTHY' ? Icons.check : Icons.warning,
                        color: health == 'HEALTHY' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '系統狀態: $health',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: health == 'HEALTHY' ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 修復建議
                if (suggestions.isNotEmpty) ...[
                  const Text(
                    '修復建議:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(suggestion)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
                
                // 詳細結果（折疊式）
                ExpansionTile(
                  title: const Text('詳細測試結果'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildTestResultWidgets(testResult),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          if (health != 'HEALTHY')
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // 嘗試修復
                await context.read<FlagStatusProvider>().refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已嘗試重新初始化系統'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              child: const Text('嘗試修復'),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTestResultWidgets(Map<String, dynamic> result) {
    final widgets = <Widget>[];
    
    result.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '$key:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        value.forEach((subKey, subValue) {
          Color textColor = Colors.black87;
          if (subKey.contains('error') || subValue == false) {
            textColor = Colors.red;
          } else if (subValue == true) {
            textColor = Colors.green;
          }
          
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Text(
                '$subKey: $subValue',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          );
        });
      } else {
        Color textColor = Colors.black87;
        if (key.contains('error') || value == false) {
          textColor = Colors.red;
        } else if (value == true) {
          textColor = Colors.green;
        }
        
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '$key: $value',
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ),
        );
      }
    });
    
    return widgets;
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤詳情'),
        content: SingleChildScrollView(
          child: Text(error),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
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