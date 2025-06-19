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
  List<String> outputLines = [];
  String myName = "你的名字";
  int myAge = 13;
  List<String> favoriteSubjects = ["數學", "英語", "程式設計"];
  bool showDartPractice = false;

  final questions = [
    {
      'question': 'Flutter 是什麼？',
      'options': ['前端框架', '後端語言', '資料庫', '作業系統'],
      'answer': 0,
      'explanation': 'Flutter 是 Google 開發的開源 UI 框架，用於構建跨平台應用程式。',
    },
    {
      'question': 'Dart 是什麼？',
      'options': ['程式語言', '設計工具', '資料庫', '瀏覽器'],
      'answer': 0,
      'explanation': 'Dart 是 Google 開發的程式語言，是 Flutter 的主要開發語言。',
    },
    {
      'question': 'Flutter 的主要優勢是什麼？',
      'options': ['跨平台開發', '後端處理', '資料庫管理', '網路安全'],
      'answer': 0,
      'explanation': 'Flutter 可以同時開發 iOS 和 Android 應用程式，大大節省開發時間。',
    },
    {
      'question': 'Widget 在 Flutter 中代表什麼？',
      'options': ['UI 組件', '資料庫', '網路請求', '檔案系統'],
      'answer': 0,
      'explanation': 'Widget 是 Flutter 中 UI 的基本構建塊，所有 UI 元素都是 Widget。',
    },
  ];

  @override
  void initState() {
    super.initState();
    runDartPractice();
  }

  void runDartPractice() {
    List<String> output = [];
    
    // 模擬原來的 print 輸出
    output.add("大家好！我是 $myName");
    output.add("我今年 $myAge 歲");
    output.add("我最喜歡的科目有：");
    
    for (String subject in favoriteSubjects) {
      output.add("- $subject");
    }
    
    output.add("Hello, $myName! 歡迎學習 Flutter！");
    
    int result = calculateAge(myAge, 5);
    output.add("5年後我會是 $result 歲");
    
    // 練習更多 Dart 語法
    output.add("");
    output.add("🎯 讓我們練習更多 Dart 語法：");
    
    int hour = DateTime.now().hour;
    if (hour < 12) {
      output.add("早安！現在是上午時光，適合學習程式設計！");
    } else if (hour < 18) {
      output.add("午安！下午也是寫程式的好時間！");
    } else {
      output.add("晚安！晚上寫程式要記得休息眼睛！");
    }
    
    Map<String, String> programmingLanguages = {
      "Dart": "Flutter 開發",
      "Python": "AI 和數據分析",
      "JavaScript": "網頁開發",
    };
    
    output.add("");
    output.add("🖥️ 熱門程式語言：");
    programmingLanguages.forEach((language, use) {
      output.add("$language - 用於 $use");
    });
    
    List<int> numbers = [1, 2, 3, 4, 5];
    int sum = numbers.reduce((a, b) => a + b);
    output.add("");
    output.add("🔢 數字 $numbers 的總和是：$sum");
    
    setState(() {
      outputLines = output;
    });
  }

  int calculateAge(int currentAge, int yearsLater) {
    return currentAge + yearsLater;
  }

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

  void resetQuiz() {
    setState(() {
      current = 0;
      score = 0;
      isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('💻 快速練習'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.pushNamed(context, '/learning-center');
            },
            tooltip: '前往學習中心',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 歡迎區域
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 快速練習中心',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 4),
                  Text(
                    '透過互動式練習鞏固你的 Flutter 知識',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 練習模式選擇
            Text(
              '📚 選擇練習模式',
              style: TextStyle(
                fontSize: isDesktop ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            
            if (isDesktop) ...[
              Row(
                children: [
                  Expanded(
                    child: PracticeModeCard(
                      title: '🎲 知識測驗',
                      subtitle: 'Flutter 基礎知識測試',
                      description: '透過選擇題測試你的 Flutter 知識',
                      icon: Icons.quiz,
                      isSelected: !showDartPractice,
                      isDesktop: isDesktop,
                      onTap: () => setState(() => showDartPractice = false),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: PracticeModeCard(
                      title: '💻 Dart 練習',
                      subtitle: '互動式 Dart 語法學習',
                      description: '體驗 Dart 變數、函數、條件判斷等基礎語法',
                      icon: Icons.code,
                      isSelected: showDartPractice,
                      isDesktop: isDesktop,
                      onTap: () => setState(() => showDartPractice = true),
                    ),
                  ),
                ],
              ),
            ] else ...[
              PracticeModeCard(
                title: '🎲 知識測驗',
                subtitle: 'Flutter 基礎知識測試',
                description: '透過選擇題測試你的 Flutter 知識',
                icon: Icons.quiz,
                isSelected: !showDartPractice,
                isDesktop: isDesktop,
                onTap: () => setState(() => showDartPractice = false),
              ),
              SizedBox(height: 12),
              PracticeModeCard(
                title: '💻 Dart 練習',
                subtitle: '互動式 Dart 語法學習',
                description: '體驗 Dart 變數、函數、條件判斷等基礎語法',
                icon: Icons.code,
                isSelected: showDartPractice,
                isDesktop: isDesktop,
                onTap: () => setState(() => showDartPractice = true),
              ),
            ],
            
            SizedBox(height: isDesktop ? 32 : 24),
            
            // 內容區域
            if (!showDartPractice) ...[
              // 知識測驗
              _buildQuizSection(isDesktop),
            ] else ...[
              // Dart 練習
              _buildDartPracticeSection(isDesktop),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(bool isDesktop) {
    final q = questions[current] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分數和進度
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '分數：$score / ${questions.length}',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Text(
                    '進度：${current + 1} / ${questions.length}',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              LinearProgressIndicator(
                value: (current + 1) / questions.length,
                backgroundColor: Colors.orange.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: isDesktop ? 8 : 6,
              ),
            ],
          ),
        ),
        
        SizedBox(height: isDesktop ? 24 : 16),
        
        // 問題卡片
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '問題 ${current + 1}',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  q['question'] as String,
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : 16),
                
                // 選項
                ...List.generate((q['options'] as List).length, (idx) {
                  final isSelected = isCorrect != null && idx == q['answer'];
                  final isWrong = isCorrect != null && !isCorrect! && idx == questions[current]['answer'];
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.green.shade50 
                          : isWrong 
                              ? Colors.red.shade50 
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.green 
                            : isWrong 
                                ? Colors.red 
                                : Colors.grey.shade300,
                        width: isSelected || isWrong ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        (q['options'] as List)[idx],
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: isSelected || isWrong ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      leading: Radio<int>(
                        value: idx,
                        groupValue: isCorrect == null ? null : q['answer'] as int?,
                        onChanged: isCorrect == null
                            ? (v) => checkAnswer(idx)
                            : null,
                        activeColor: Colors.orange,
                      ),
                      onTap: isCorrect == null ? () => checkAnswer(idx) : null,
                    ),
                  );
                }),
                
                // 結果和解釋
                if (isCorrect != null) ...[
                  SizedBox(height: isDesktop ? 20 : 16),
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 16 : 12),
                    decoration: BoxDecoration(
                      color: isCorrect! ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect! ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect! ? Icons.check_circle : Icons.cancel,
                              color: isCorrect! ? Colors.green : Colors.red,
                              size: isDesktop ? 24 : 20,
                            ),
                            SizedBox(width: isDesktop ? 8 : 6),
                            Text(
                              isCorrect! ? '答對了！' : '答錯了！',
                              style: TextStyle(
                                color: isCorrect! ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 8 : 6),
                        Text(
                          q['explanation'] as String,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 20 : 16),
                  
                  Row(
                    children: [
                      if (current < questions.length - 1)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: nextQuestion,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('下一題'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: resetQuiz,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新開始'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDartPracticeSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 頂部說明
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎉 恭喜！你的 Dart 程式在瀏覽器中運行',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Text(
                '這就是將控制台程式轉換為 Flutter UI 的過程！',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isDesktop ? 24 : 16),
        
        // 輸入區域
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📝 修改你的資訊：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16 : 14,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: '你的名字',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) {
                  setState(() {
                    myName = value.isEmpty ? "你的名字" : value;
                  });
                  runDartPractice();
                },
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Row(
                children: [
                  Text(
                    '年齡：',
                    style: TextStyle(fontSize: isDesktop ? 16 : 14),
                  ),
                  Expanded(
                    child: Slider(
                      value: myAge.toDouble(),
                      min: 10,
                      max: 18,
                      divisions: 8,
                      label: myAge.toString(),
                      onChanged: (value) {
                        setState(() {
                          myAge = value.round();
                        });
                        runDartPractice();
                      },
                    ),
                  ),
                  Text(
                    '$myAge 歲',
                    style: TextStyle(fontSize: isDesktop ? 16 : 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: isDesktop ? 24 : 16),
        
        // 輸出區域
        Container(
          height: isDesktop ? 400 : 300,
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade600),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal, color: Colors.green),
                  SizedBox(width: isDesktop ? 8 : 6),
                  Text(
                    '程式輸出：',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: outputLines.map((line) => Padding(
                      padding: EdgeInsets.symmetric(vertical: isDesktop ? 3 : 2),
                      child: Text(
                        line,
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'monospace',
                          fontSize: isDesktop ? 14 : 12,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isDesktop ? 24 : 16),
        
        // 操作按鈕
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: runDartPractice,
                icon: const Icon(Icons.refresh),
                label: const Text('重新執行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/learning-center');
                },
                icon: const Icon(Icons.school),
                label: const Text('前往學習中心'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PracticeModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isDesktop;
  final VoidCallback onTap;

  const PracticeModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.orange.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.orange : Colors.grey.shade600,
                      size: isDesktop ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.orange.shade700 : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: isSelected ? Colors.orange.shade600 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                      size: isDesktop ? 24 : 20,
                    ),
                ],
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
