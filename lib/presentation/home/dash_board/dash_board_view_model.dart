import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/dash_board/dash_board_state.dart';

import '../../../core/const/info_text.dart';
import '../../../core/const/size.dart';
import '../../../core/di/setup.dart';
import '../../../core/router/router.dart';
import '../../../core/router/router_path.dart';
import '../../../data/data_source/remote/fbase.dart';
import '../../../domain/model/user_model.dart';
import 'enum/menu_status.dart';

class DashBoardViewModel with ChangeNotifier {
  DashBoardViewModel() {
    _init();
  }

  DashBoardState _state = DashBoardState();

  DashBoardState get state => _state;

  final _userSession = getIt<UserSession>();

  Future<void> _init() async {
    await _userSession.loadManagePeriodFromPrefs(); // 관리주기 로드

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null && _userSession.currentUser == null) {
      final snapshot = await getIt<FBase>().getUserInfo();
      final user = UserModel.fromSnapshot(snapshot);
      _userSession.setUserModel(user);
    }

    if (firebaseUser != null) {
      await loadData();
    }
  }

  Future<void> loadData() async {
    try {
      _state = state.copyWith(isLoading: true);
      notifyListeners();
      if (UserSession.userId.isEmpty) {
        log('UserSession.userId is empty');
        throw Exception('User ID is not set');
      }
      final customersAllData =
          await getIt<CustomerUseCase>().execute(
                usecase: GetAllDataUseCase(userKey: UserSession.userId),
              )
              as List<CustomerModel>;

      final contractGrouped = <String, List<CustomerModel>>{};
      final prospectGrouped = <String, List<CustomerModel>>{};

      for (var customer in customersAllData) {
        if (customer.policies.isEmpty) {
          final regDate = customer.registeredDate;
          final regMonth =
              '${regDate.year}-${regDate.month.toString().padLeft(2, '0')}';
          prospectGrouped.putIfAbsent(regMonth, () => []).add(customer);
          continue;
        }

        for (var policy in customer.policies) {
          final startDate = policy.startDate;
          if (startDate == null) continue;
          final contractMonth =
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';
          contractGrouped.putIfAbsent(contractMonth, () => []).add(customer);
        }
      }

      final monthlyGrouped = <String, Map<String, List<CustomerModel>>>{};
      final allMonths =
          <String>{...prospectGrouped.keys, ...contractGrouped.keys}.toList()
            ..sort();

      for (var month in allMonths) {
        monthlyGrouped[month] = {
          'prospect': prospectGrouped[month] ?? [],
          'contract': contractGrouped[month] ?? [],
        };
      }

      _state = state.copyWith(
        monthlyCustomers: monthlyGrouped,
        customers: customersAllData,
        histories: customersAllData.expand((e) => e.histories).toList(),
        policies: customersAllData.expand((e) => e.policies).toList(),
        isLoading: false,
      );

      notifyListeners();
    } catch (e, stack) {
      log('loadData error: $e\n$stack');
    }
  }

  /// 메뉴 열고 닫기
  Future<void> toggleMenu(AnimationController controller) async {
    final isOpening = state.menuStatus == MenuStatus.isClosed;

    if (isOpening) {
      // 사용자 정보가 없다면 Firestore에서 가져와서 UserSession에 저장
      final snapshot = await getIt<FBase>().getUserInfo();
      final user = UserModel.fromSnapshot(snapshot);
      _userSession.setUserModel(user);

      // 상태에 반영
      _state = state.copyWith(userInfo: _userSession.currentUser);

      // 메뉴 애니메이션 열기
      controller.forward();
      _state = state.copyWith(
        menuStatus: MenuStatus.isOpened,
        bodyXPosition: -AppSizes.myMenuWidth,
        menuXPosition: AppSizes.deviceSize.width - AppSizes.myMenuWidth,
      );
    } else {
      // 메뉴 닫기
      controller.reverse();
      _state = state.copyWith(
        menuStatus: MenuStatus.isClosed,
        bodyXPosition: 0,
        menuXPosition: AppSizes.deviceSize.width,
      );
    }

    notifyListeners();
  }

  void forceCloseMenu() {
    if (state.menuStatus == MenuStatus.isOpened) {
      _state = state.copyWith(
        menuStatus: MenuStatus.isClosed,
        bodyXPosition: 0,
        menuXPosition: AppSizes.deviceSize.width,
      );
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    getIt<UserSession>().clear(); // 상태 초기화
    getIt<UserSession>().clearAgreement();
    getIt<AuthChangeNotifier>().setLoggedIn(false);
    if (context.mounted) context.go(RoutePath.login);
  }

  Future<void> signOut(
    BuildContext context,
    Map<String, dynamic> credentials,
  ) async {
    await getIt<FBase>().deleteUserAccountAndData(
      userId: UserSession.userId,
      email: credentials['email']!,
      password: credentials['password']!,
    );
    getIt<UserSession>().clear(); // 상태 초기화
    getIt<AuthChangeNotifier>().setLoggedIn(false);
    if (context.mounted) context.go(RoutePath.login);
  }

  void sendInquiryEmail(BuildContext context) async {
    final email = _userSession.currentUser?.email ?? 'unknown@unknown.com';

    final Uri emailUri = Uri.parse(
      'mailto:$adminEmail?subject=${Uri.encodeComponent("유료회원 문의")}'
      '&body=${Uri.encodeComponent("안녕하세요,\n\n유저 이메일: $email\n\n유료회원 가입에 대해 문의드립니다.")}',
    );

    final bool launched = await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('메일 앱 없음'),
              content: const Text(
                '메일 앱이 설치되어 있지 않거나 실행할 수 없습니다.\n앱스토어에서 메일 앱을 설치해 주세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: adminEmail),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이메일 주소가 복사되었습니다.')),
                    );
                  },
                  child: const Text('이메일 복사'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    }
  }
}

