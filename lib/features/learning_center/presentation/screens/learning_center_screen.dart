import 'package:flutter/material.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chapters = [
      {'title': '認識 Flutter', 'desc': '快速了解 Flutter 與 Dart', 'progress': 0.8},
      {'title': 'Widget 基礎', 'desc': '掌握常用 Widget', 'progress': 0.5},
      {'title': '狀態管理', 'desc': 'Provider、Bloc、Riverpod', 'progress': 0.2},
    ];
    final totalProgress =
        chapters.map((c) => c['progress'] as double).reduce((a, b) => a + b) /
            chapters.length;

    return Scaffold(
      appBar: AppBar(title: const Text('學習中心')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('學習進度', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: totalProgress, minHeight: 10),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, idx) {
                  final c = chapters[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(c['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c['desc'] as String),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '進度 ${((c['progress'] as double) * 100).toStringAsFixed(0)}%'),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () {
                        // TODO: 導向章節詳情
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
