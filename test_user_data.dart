import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // 初始化 Firebase
  await Firebase.initializeApp();
  
  // 目標用戶信息
  const targetEmail = 'leedragotest@gmail.com';
  const targetUid = 'eRZCNMNnyUO7nRAhidr0fd1K1ch1';
  
  print('=== 檢查用戶資料 ===');
  print('Email: $targetEmail');
  print('UID: $targetUid');
  
  try {
    final ref = FirebaseDatabase.instance.ref('users/$targetUid');
    final snapshot = await ref.get();
    
    if (snapshot.exists && snapshot.value != null) {
      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      
      print('\n=== 用戶資料分析 ===');
      print('用戶名: ${userData['name'] ?? '未設定'}');
      print('地址: ${userData['address'] ?? '未設定'}');
      print('Email: ${userData['email'] ?? '未設定'}');
      
      // 檢查註冊時間
      DateTime? registrationDate;
      if (userData['lastUpdate'] != null) {
        registrationDate = DateTime.fromMillisecondsSinceEpoch(userData['lastUpdate']);
        print('最後更新時間: $registrationDate');
      }
      if (userData['creationTime'] != null) {
        final creationTime = DateTime.fromMillisecondsSinceEpoch(userData['creationTime']);
        print('創建時間: $creationTime');
        if (registrationDate == null) {
          registrationDate = creationTime;
        }
      }
      
      // 檢查互助旗狀態
      final flagDown = userData['flag_down'] as bool? ?? false;
      final hasFlag = !flagDown;
      print('互助旗狀態: ${hasFlag ? '升起' : '降下'} (flag_down: $flagDown)');
      
      // 檢查是否符合新朋友活動條件
      print('\n=== 新朋友活動條件檢查 ===');
      
      if (registrationDate == null) {
        print('❌ 無法確定註冊時間');
      } else {
        final now = DateTime.now();
        final filterDate = now.subtract(const Duration(days: 30));
        final isRecent = registrationDate.isAfter(filterDate);
        
        print('註冊時間: $registrationDate');
        print('過濾日期: $filterDate');
        print('是否在30天內註冊: $isRecent');
        print('互助旗是否升起: $hasFlag');
        
        if (isRecent && hasFlag) {
          print('✅ 符合新朋友活動條件！');
        } else {
          print('❌ 不符合新朋友活動條件');
          if (!isRecent) {
            print('   - 註冊時間超過30天');
          }
          if (!hasFlag) {
            print('   - 互助旗已降下');
          }
        }
      }
      
      // 顯示所有可用欄位
      print('\n=== 所有可用欄位 ===');
      userData.forEach((key, value) {
        print('$key: $value');
      });
      
    } else {
      print('❌ 找不到用戶資料');
    }
    
  } catch (e) {
    print('❌ 檢查用戶資料時發生錯誤: $e');
  }
} 