import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('📚 學習中心'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 歡迎區域
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 32 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade100, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 歡迎來到學習中心！',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),
                  Text(
                    '這裡是你的 Flutter 和 Dart 學習基地',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 第一週學習區域
            Text(
              '📖 第一週：基礎學習',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            
            // Dart 基礎練習卡片
            LearningCard(
              title: '🚀 Dart 基礎練習',
              subtitle: '互動式 Dart 語法學習',
              description: '體驗 Dart 變數、函數、條件判斷等基礎語法',
              color: Colors.orange,
              icon: Icons.code,
              isDesktop: isDesktop,
              onTap: () {
                Navigator.pushNamed(context, '/quick-practice');
              },
            ),
            
            SizedBox(height: isDesktop ? 16 : 12),
            
            // 第一週指南卡片
            LearningCard(
              title: '📝 第一週學習指南',
              subtitle: 'Flutter 和 Dart 基礎概念',
              description: '完整的第一週學習計畫和練習任務',
              color: Colors.green,
              icon: Icons.menu_book,
              isDesktop: isDesktop,
              onTap: () {
                _showWeek1Guide(context, isDesktop);
              },
            ),
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 快速操作區域
            Text(
              '⚡ 快速操作',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            
            if (isDesktop) ...[
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      title: '💻 終端練習',
                      subtitle: '在終端執行 Dart',
                      icon: Icons.terminal,
                      isDesktop: isDesktop,
                      onTap: () {
                        _showTerminalInstructions(context, isDesktop);
                      },
                    ),
                  ),
                  SizedBox(width: isDesktop ? 16 : 12),
                  Expanded(
                    child: QuickActionCard(
                      title: '🌐 線上編輯器',
                      subtitle: 'DartPad 體驗',
                      icon: Icons.web,
                      isDesktop: isDesktop,
                      onTap: () {
                        _showDartPadInstructions(context, isDesktop);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      title: '🎯 快速練習',
                      subtitle: '知識測驗與 Dart 練習',
                      icon: Icons.quiz,
                      isDesktop: isDesktop,
                      onTap: () {
                        Navigator.pushNamed(context, '/quick-practice');
                      },
                    ),
                  ),
                  SizedBox(width: isDesktop ? 16 : 12),
                  Expanded(
                    child: QuickActionCard(
                      title: '📚 學習指南',
                      subtitle: '完整學習計畫',
                      icon: Icons.menu_book,
                      isDesktop: isDesktop,
                      onTap: () {
                        _showWeek1Guide(context, isDesktop);
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              QuickActionCard(
                title: '💻 終端練習',
                subtitle: '在終端執行 Dart',
                icon: Icons.terminal,
                isDesktop: isDesktop,
                onTap: () {
                  _showTerminalInstructions(context, isDesktop);
                },
              ),
              SizedBox(height: 12),
              QuickActionCard(
                title: '🌐 線上編輯器',
                subtitle: 'DartPad 體驗',
                icon: Icons.web,
                isDesktop: isDesktop,
                onTap: () {
                  _showDartPadInstructions(context, isDesktop);
                },
              ),
              SizedBox(height: 12),
              QuickActionCard(
                title: '🎯 快速練習',
                subtitle: '知識測驗與 Dart 練習',
                icon: Icons.quiz,
                isDesktop: isDesktop,
                onTap: () {
                  Navigator.pushNamed(context, '/quick-practice');
                },
              ),
              SizedBox(height: 12),
              QuickActionCard(
                title: '📚 學習指南',
                subtitle: '完整學習計畫',
                icon: Icons.menu_book,
                isDesktop: isDesktop,
                onTap: () {
                  _showWeek1Guide(context, isDesktop);
                },
              ),
            ],
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 學習進度區域
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 學習進度',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  ProgressItem(
                    title: '環境設置',
                    isCompleted: true,
                    isDesktop: isDesktop,
                  ),
                  ProgressItem(
                    title: 'Dart 基礎語法',
                    isCompleted: false,
                    isDesktop: isDesktop,
                  ),
                  ProgressItem(
                    title: 'Flutter Widget',
                    isCompleted: false,
                    isDesktop: isDesktop,
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),
                  LinearProgressIndicator(
                    value: 0.33,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: isDesktop ? 12 : 8,
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),
                  Text(
                    '進度：33% (1/3 完成)',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 學習章節區域
            Text(
              '📚 學習章節',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            
            ..._getLearningChapters(isDesktop).map((chapter) => 
              ChapterCard(
                chapter: chapter,
                isDesktop: isDesktop,
                onTap: () {
                  _showChapterDetails(context, chapter, isDesktop);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getLearningChapters(bool isDesktop) {
    return [
      {
        'title': '認識 Flutter',
        'desc': '快速了解 Flutter 與 Dart',
        'progress': 0.8,
        'icon': Icons.flutter_dash,
        'color': Colors.blue,
      },
      {
        'title': 'Widget 基礎',
        'desc': '掌握常用 Widget',
        'progress': 0.5,
        'icon': Icons.widgets,
        'color': Colors.green,
      },
      {
        'title': '狀態管理',
        'desc': 'Provider、Bloc、Riverpod',
        'progress': 0.2,
        'icon': Icons.settings,
        'color': Colors.orange,
      },
    ];
  }

  void _showWeek1Guide(BuildContext context, bool isDesktop) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('第一週學習指南功能開發中...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showChapterDetails(BuildContext context, Map<String, dynamic> chapter, bool isDesktop) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${chapter['title']} 章節詳情功能開發中...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showTerminalInstructions(BuildContext context, bool isDesktop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.terminal, color: Colors.green),
            SizedBox(width: isDesktop ? 12 : 8),
            Text(
              '終端執行 Dart',
              style: TextStyle(fontSize: isDesktop ? 20 : 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '在終端機中執行以下命令：',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            SelectableText(
              'dart practice/dart_basics.dart',
              style: TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.black87,
                color: Colors.green,
                fontSize: isDesktop ? 16 : 14,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              '這會在控制台顯示你的 Dart 練習結果！',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '知道了',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDartPadInstructions(BuildContext context, bool isDesktop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.web, color: Colors.blue),
            SizedBox(width: isDesktop ? 12 : 8),
            Text(
              'DartPad 線上編輯器',
              style: TextStyle(fontSize: isDesktop ? 20 : 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. 前往 dartpad.dev',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            Text(
              '2. 選擇 "New Pad" > "Dart"',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            Text(
              '3. 複製 dart_basics.dart 的程式碼',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            Text(
              '4. 貼上並點擊 "Run" 按鈕',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              '你可以在線上編輯和執行 Dart 程式！',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '知道了',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }
}

class LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;
  final bool isDesktop;
  final VoidCallback onTap;

  const LearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 32 : 24,
                ),
              ),
              SizedBox(width: isDesktop ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 8 : 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: isDesktop ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDesktop;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: isDesktop ? 48 : 32,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isDesktop;

  const ProgressItem({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: isDesktop ? 24 : 20,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: isCompleted ? Colors.green : Colors.grey.shade700,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final bool isDesktop;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  color: chapter['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  chapter['icon'],
                  color: chapter['color'],
                  size: isDesktop ? 28 : 24,
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter['title'],
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      chapter['desc'],
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 8 : 4),
                    LinearProgressIndicator(
                      value: chapter['progress'],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(chapter['color']),
                      minHeight: isDesktop ? 8 : 6,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '進度 ${((chapter['progress'] as double) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: chapter['color'],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isDesktop ? 18 : 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
