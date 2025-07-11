import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/model/user_model.dart';

// class UserSession {
//   static String get userId => FirebaseAuth.instance.currentUser?.uid??'';
// }
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
  void setUserModel(UserModel user) {
    _currentUser = user;
    _managePeriodDays = user.prospectCycleDays ?? 60;
    _saveManagePeriodToPrefs(_managePeriodDays); // 🟢 SharedPreferences 동기화
    notifyListeners(); // ✅ 변경 알림
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

// class UserSession {
//   /// 현재 Firebase 사용자 ID (nullable-safe)
//   static String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';
//
//   /// 현재 사용자 모델 (앱 내부용)
//   UserModel? _currentUser;
//
//   /// 저장된 관리 주기 (기본 60일, SharedPreferences or Firestore 기반)
//   int managePeriodDays = 60;
//
//   /// 현재 사용자 모델 getter
//   UserModel? get currentUser => _currentUser;
//
//   /// 사용자 모델 설정
//   void setUserModel(UserModel user) {
//     _currentUser = user;
//     managePeriodDays = user.prospectCycleDays ?? 60;
//   }
//
//   /// 관리 주기 설정
//   void updateManagePeriod(int days) {
//     managePeriodDays = days;
//   }
// }
