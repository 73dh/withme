import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/model/user_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/model/user_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // debugPrint를 위해 필요
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/model/user_model.dart'; // UserModel 경로 확인 필요

class UserSession extends ChangeNotifier {
  // 싱글톤 인스턴스: 앱 전체에서 단 하나의 UserSession 인스턴스만 존재합니다.
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  // 내부 생성자: _init 메서드를 호출하여 초기 설정을 수행합니다.
  UserSession._internal() {
    _init();
  }

  // 초기화 메서드: SharedPreferences에서 관리 주기를 로드합니다.
  Future<void> _init() async {
    await loadManagePeriodFromPrefs();
    await loadUrgentThresholdFromPrefs(); // 추가
  }

  /// Firebase 현재 로그인된 사용자의 UID를 반환합니다.
  /// 사용자가 로그인되어 있지 않으면 빈 문자열을 반환합니다.
  static String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// 현재 로그인된 사용자 모델을 저장하는 내부 변수입니다.
  static UserModel? _currentUser;

  /// [currentUser] 게터: 현재 로그인된 [UserModel]을 반환합니다.
  UserModel? get currentUser => _currentUser;

  /// 가망 고객 관리 주기 (일 단위). SharedPreferences에서 관리됩니다.
  /// 기본값은 60일입니다.
  int _managePeriodDays = 60;

  /// [managePeriodDays] 게터: 현재 설정된 관리 주기를 반환합니다.
  int get managePeriodDays => _managePeriodDays;

  /// 사용자 모델을 설정합니다.
  /// 이 메서드는 사용자가 로그인하거나, 앱 시작 시 사용자 세션을 복원할 때 호출됩니다.
  Future<void> setUserModel(UserModel user) async {
    _currentUser = user;
    // 사용자 모델이 설정될 때 관리 주기를 다시 로드하여 최신 상태를 유지할 수 있습니다.
    // 하지만 _init에서 이미 로드하고 있으므로, 여기서는 필수는 아닐 수 있습니다.
    // await loadManagePeriodFromPrefs(); // 필요에 따라 주석 해제
    notifyListeners(); // currentUser가 변경되었음을 알립니다.
  }

  /// 가망 고객 관리 주기를 [days] 값으로 업데이트하고,
  /// SharedPreferences에 저장하며, UI에 변경을 알립니다.
  void updateManagePeriod(int days) {
    _managePeriodDays = days; // 내부 상태 업데이트
    _saveManagePeriodToPrefs(days); // SharedPreferences에 저장


    notifyListeners(); // 이 클래스를 구독하는 모든 리스너에게 변경 사항을 알립니다.
  }

  /// SharedPreferences에서 가망 고객 관리 주기를 로드합니다.
  /// 로드된 값은 [_managePeriodDays]에 저장되고 UI에 반영됩니다.
  Future<void> loadManagePeriodFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 값이 없으면 기본값인 60일을 사용합니다.
    _managePeriodDays = prefs.getInt('managePeriodDays') ?? 60;
    notifyListeners(); // 관리 주기가 로드되었음을 알립니다.
  }

  /// 현재 [days] 값을 SharedPreferences에 저장합니다.
  /// 이 메서드는 [updateManagePeriod] 내부에서 호출됩니다.
  Future<void> _saveManagePeriodToPrefs(int days) async {
    debugPrint('SharedPreferences: Saving managePeriodDays = $days');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('managePeriodDays', days);
  }

  /// 사용자 세션 정보를 모두 초기화합니다.
  /// (예: 로그아웃 시 호출)
  void clear() {
    _currentUser = null; // 사용자 모델 초기화
    // SharedPreferences에 저장된 관리 주기 값은 유지됩니다.
    // 만약 이 값도 제거하고 싶다면 아래 라인을 추가하세요:
    // SharedPreferences.getInstance().then((prefs) => prefs.remove('managePeriodDays'));
    notifyListeners(); // 모든 리스너에게 상태 초기화를 알립니다.
  }

  int _urgentThresholdDays = 90;

  int get urgentThresholdDays => _urgentThresholdDays;

  void updateUrgentThresholdDays(int days) {
    _urgentThresholdDays = days;
    _saveUrgentThresholdToPrefs(days);
    notifyListeners();
  }

  Future<void> _saveUrgentThresholdToPrefs(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('urgentThresholdDays', days);
  }

  Future<void> loadUrgentThresholdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _urgentThresholdDays = prefs.getInt('urgentThresholdDays') ?? 90;
    notifyListeners();
  }
}

