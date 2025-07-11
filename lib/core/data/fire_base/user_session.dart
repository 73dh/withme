import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/model/user_model.dart';

class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  /// Firebase 현재 사용자 ID
  static String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// 내부 사용자 모델
  UserModel? _currentUser;

  /// 관리 주기 (기본 60일)
  int _managePeriodDays = 60;

  /// Getter
  UserModel? get currentUser => _currentUser;

  int get managePeriodDays => _managePeriodDays;

  /// 사용자 모델 설정

  Future<void> setUserModel(UserModel user) async {
    _currentUser = user;
    await loadManagePeriodFromPrefs(); // ✅ 캐시에서만 관리주기 로드
  }

  /// 관리 주기 수동 업데이트
  void updateManagePeriod(int days) {
    _managePeriodDays = days;
    _saveManagePeriodToPrefs(days); // 🟢 저장 함께 수행
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(prospectCycleDays: days);
    }
    notifyListeners(); // ✅ 변경 알림
  }

  /// SharedPreferences에서 관리주기 로드
  Future<void> loadManagePeriodFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _managePeriodDays = prefs.getInt('managePeriodDays') ?? 60;
    notifyListeners(); // ✅ 변경 알림
  }

  /// SharedPreferences에 저장
  Future<void> _saveManagePeriodToPrefs(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('managePeriodDays', days);
  }

  /// 전체 초기화 (로그아웃 등)
  void clear() {
    _currentUser = null;
    _managePeriodDays = 60;
  }
}
