import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FlagStatusProvider extends ChangeNotifier {
  bool _isFlagDown = false;
  bool _isLoading = false;

  bool get isFlagDown => _isFlagDown;
  bool get isLoading => _isLoading;
  
  /// 互助旗是否升起（可見狀態）
  bool get isFlagUp => !_isFlagDown;
  
  /// 狀態文字描述
  String get statusText => _isFlagDown ? '任務完成 - 互助旗已降下' : '互助旗升起中';
  
  /// 狀態圖示
  IconData get statusIcon => _isFlagDown ? Icons.flag_outlined : Icons.flag;
  
  /// 狀態顏色
  Color get statusColor => _isFlagDown ? Colors.grey : Colors.orange;

  FlagStatusProvider() {
    _loadFlagStatus();
  }

  /// 從本地和 Firebase 載入互助旗狀態
  Future<void> _loadFlagStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 先從本地載入
      final prefs = await SharedPreferences.getInstance();
      _isFlagDown = prefs.getBool('flag_down') ?? false;
      notifyListeners();

      // 再從 Firebase 同步
      await _syncFromFirebase();
    } catch (e) {
      debugPrint('載入互助旗狀態時發生錯誤: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 從 Firebase 同步狀態
  Future<void> _syncFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseDatabase.instance.ref('users/${user.uid}/flag_down');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final firebaseStatus = snapshot.value as bool? ?? false;
        if (firebaseStatus != _isFlagDown) {
          _isFlagDown = firebaseStatus;
          await _saveToLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('從 Firebase 同步互助旗狀態時發生錯誤: $e');
    }
  }

  /// 儲存狀態到本地
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('flag_down', _isFlagDown);
    } catch (e) {
      debugPrint('儲存互助旗狀態到本地時發生錯誤: $e');
    }
  }

  /// 儲存狀態到 Firebase
  Future<void> _saveToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
      await ref.update({
        'flag_down': _isFlagDown,
        'last_flag_update': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('儲存互助旗狀態到 Firebase 時發生錯誤: $e');
      throw e;
    }
  }

  /// 設定互助旗狀態
  Future<void> setFlagStatus(bool flagDown) async {
    if (_isFlagDown == flagDown) return;

    try {
      _isLoading = true;
      notifyListeners();

      _isFlagDown = flagDown;
      
      // 同時儲存到本地和 Firebase
      await Future.wait([
        _saveToLocal(),
        _saveToFirebase(),
      ]);

      notifyListeners();
      
      debugPrint('互助旗狀態已更新: ${flagDown ? "降下" : "升起"}');
    } catch (e) {
      // 如果儲存失敗，回復原狀態
      _isFlagDown = !flagDown;
      debugPrint('更新互助旗狀態時發生錯誤: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 降下互助旗（任務完成）
  Future<void> lowerFlag() async {
    await setFlagStatus(true);
  }

  /// 升起互助旗（重新開始尋求協助）
  Future<void> raiseFlag() async {
    await setFlagStatus(false);
  }

  /// 切換互助旗狀態
  Future<void> toggleFlag() async {
    await setFlagStatus(!_isFlagDown);
  }

  /// 重新載入狀態（用於手動刷新）
  Future<void> refresh() async {
    await _loadFlagStatus();
  }
} 