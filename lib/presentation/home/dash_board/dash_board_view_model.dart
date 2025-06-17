import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/dash_board/dash_board_state.dart';

import '../../../core/di/setup.dart';
import '../../../core/router/router.dart';
import '../../../core/router/router_path.dart';

class DashBoardViewModel with ChangeNotifier {
  DashBoardViewModel() {
    _init();
  }

  DashBoardState _state = DashBoardState();

  DashBoardState get state => _state;

  Future<void> _init() async {
    await loadData(); // async 함수 별도로 실행
  }

  Future<void> loadData() async {
    try {
      _state = state.copyWith(isLoading: true);
      notifyListeners();

      final customersAllData =
          await getIt<CustomerUseCase>().execute(
                usecase: GetAllDataUseCase(userKey: UserSession.userId),
              )
              as List<CustomerModel>;

      // 월별 계약 고객 그룹 (startDate 기준)
      final Map<String, List<CustomerModel>> contractGrouped = {};

      // 월별 가망 고객 그룹 (registeredDate 기준, 계약 없는 고객)
      final Map<String, List<CustomerModel>> prospectGrouped = {};

      for (var customer in customersAllData) {
        // 가망 고객 (계약 없는 고객)
        if (customer.policies.isEmpty || customer.policies.isEmpty) {
          final regDate = customer.registeredDate;
          final regMonth =
              '${regDate.year}-${regDate.month.toString().padLeft(2, '0')}';

          prospectGrouped.putIfAbsent(regMonth, () => []);
          prospectGrouped[regMonth]!.add(customer);
          continue; // 계약 없으니 아래 계약 처리 건너뜀
        }

        // 계약 고객 - 계약별 startDate 기준
        for (var policy in customer.policies) {
          final startDate = policy.startDate;
          if (startDate == null) continue;

          final contractMonth =
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';

          contractGrouped.putIfAbsent(contractMonth, () => []);
          contractGrouped[contractMonth]!.add(customer);
        }
      }

      // 여기서 월별로 둘 다 합쳐서 원하는 형태로 사용 가능
      // 예: 한 map에 month별로 { 'prospect': [...], 'contract': [...] } 형태

      final Map<String, Map<String, List<CustomerModel>>> monthlyGrouped = {};

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
      log(e.toString());
    }
  }

  Future<void> logout(BuildContext context ) async {
    await FirebaseAuth.instance.signOut();
    final authChangeNotifier = getIt<AuthChangeNotifier>();
    authChangeNotifier.setLoggedIn(false); // ✅ 로그인 상태 변화 알림
   if(context.mounted){

    context.go(RoutePath.login); // ✅ 명시적으로 이동 (안전망 역할)
   }
  }
}
