import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/ui/const/shared_pref_value.dart';

import '../../../domain/model/user_model.dart';

class UserSession extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal() {
    _init();
  }

  // SharedPreferences 키 상수
  static const String _agreementSeenKey = 'hasAgreed'; //최초 동의여부
  static const String _managePeriodKey = 'managePeriodDays'; // 관리주기
  static const String _urgentThresholdKey = 'urgentThresholdDays'; //상령일
  static const String _targetProspectCountKey = 'targetProspectCount'; // 목표고객수

  /// 초기화 메서드
  Future<void> _init() async {
    await loadManagePeriodFromPrefs();
    await loadUrgentThresholdFromPrefs();
    await loadAgreementCheckFromPrefs();
    await loadTargetProspectCountFromPrefs();
  }

  // 현재 Firebase 로그인 유저 UID
  static String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 현재 로그인된 사용자 모델
  static UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> setUserModel(UserModel user) async {
    _currentUser = user;
    notifyListeners();
  }

  // 가망고객 관리 주기 (일)
  int _managePeriodDays = SharedPrefValue.managePeriodDays;

  int get managePeriodDays => _managePeriodDays;

  // 상령일 도래일
  int _urgentThresholdDays = SharedPrefValue.urgentThresholdDays;

  int get urgentThresholdDays => _urgentThresholdDays;

  // 목표고객수
  int _targetProspectCount = SharedPrefValue.targetProspectCount;

  int get targetProspectCount => _targetProspectCount;

  // 관리주기
  void updateManagePeriod(int days) {
    _managePeriodDays = days;
    _saveManagePeriodToPrefs(days);
    notifyListeners();
  }

  Future<void> _saveManagePeriodToPrefs(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_managePeriodKey, days);
  }

  Future<void> loadManagePeriodFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _managePeriodDays =
        prefs.getInt(_managePeriodKey) ?? SharedPrefValue.managePeriodDays;
    notifyListeners();
  }

  void updateUrgentThresholdDays(int days) {
    _urgentThresholdDays = days;
    _saveUrgentThresholdToPrefs(days);
    notifyListeners();
  }

  Future<void> _saveUrgentThresholdToPrefs(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_urgentThresholdKey, days);
  }

  Future<void> loadUrgentThresholdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _urgentThresholdDays =
        prefs.getInt(_urgentThresholdKey) ??
        SharedPrefValue.urgentThresholdDays;
    notifyListeners();
  }

  // 목표고객수 관리
  void updateTargetProspectCount(int count) {
    _targetProspectCount = count;
    _saveTargetProspectCountToPrefs(count);
    notifyListeners();
  }

  Future<void> _saveTargetProspectCountToPrefs(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetProspectCountKey, count);
  }

  Future<void> loadTargetProspectCountFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _targetProspectCount =
        prefs.getInt(_targetProspectCountKey) ??
        SharedPrefValue.targetProspectCount;
    notifyListeners();
  }

  // 동의 여부 관련
  bool _hasAgreed = false;

  bool get hasAgreed => _hasAgreed;

  // 최초 로그인 판단 변수
  bool _isFirstLogin = false;

  bool get isFirstLogin => _isFirstLogin;

  /// 최초 로그인인지 SharedPreferences에서 확인
  Future<void> loadAgreementCheckFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _hasAgreed = prefs.getBool(_agreementSeenKey) ?? false;
    _isFirstLogin = !_hasAgreed;
    notifyListeners();
  }

  /// 동의 완료 시 SharedPreferences에 저장
  Future<void> markAgreementSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreementSeenKey, true);
    _hasAgreed = true;
    _isFirstLogin = false;
    notifyListeners();
  }

  // 로그아웃 등 세션 초기화
  void clear() {
    _currentUser = null;
    _hasAgreed = false;
    _isFirstLogin = false;
    notifyListeners();
  }

  Future<void> clearAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_agreementSeenKey);
  }
}
