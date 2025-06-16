import 'package:flutter/material.dart';

class QuickPracticeScreen extends StatefulWidget {
  const QuickPracticeScreen({super.key});

  @override
  State<QuickPracticeScreen> createState() => _QuickPracticeScreenState();
}

class _QuickPracticeScreenState extends State<QuickPracticeScreen> {
  int current = 0;
  int score = 0;
  bool? isCorrect;

  final questions = [
    {
      'question': 'Flutter 是什麼？',
      'options': ['前端框架', '後端語言', '資料庫', '作業系統'],
      'answer': 0,
    },
    {
      'question': 'Dart 是什麼？',
      'options': ['程式語言', '設計工具', '資料庫', '瀏覽器'],
      'answer': 0,
    },
  ];

  void checkAnswer(int idx) {
    setState(() {
      isCorrect = idx == questions[current]['answer'];
      if (isCorrect!) score++;
    });
  }

  void nextQuestion() {
    setState(() {
      current = (current + 1) % questions.length;
      isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[current] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('快速練習')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分數：$score', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q['question'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...List.generate((q['options'] as List).length, (idx) {
                      return ListTile(
                        title: Text((q['options'] as List)[idx]),
                        leading: Radio<int>(
                          value: idx,
                          groupValue: isCorrect == null ? null : q['answer'] as int?,
                          onChanged: isCorrect == null ? (v) => checkAnswer(idx) : null,
                        ),
                      );
                    }),
                    if (isCorrect != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          isCorrect! ? '答對了！' : '答錯了！',
                          style: TextStyle(
                            color: isCorrect! ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (isCorrect != null)
                      ElevatedButton(
                        onPressed: nextQuestion,
                        child: const Text('下一題'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 