import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../../domain/model/history_model.dart';
import '../../../domain/model/user_model.dart';
import 'enum/menu_status.dart';

class DashBoardState {
  final List<CustomerModel> customers;
  final List<HistoryModel> histories;
  final List<PolicyModel> policies;
  final Map<String, Map<String, List<CustomerModel>>>? monthlyCustomers;
  final UserModel? userInfo;
  final bool isLoading;

  // ✅ 메뉴 상태
  final MenuStatus menuStatus;
  final double bodyXPosition;
  final double menuXPosition;

  DashBoardState({
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.userInfo ,
    this.monthlyCustomers=const {},
    this.isLoading=false,

    this.menuStatus = MenuStatus.isClosed,
    this.bodyXPosition = 0,
    this.menuXPosition = 480, // default: 화면 너비
  });

  DashBoardState copyWith({
    List<CustomerModel>? customers,
    List<HistoryModel>? histories,
    List<PolicyModel>? policies,
    Map<String, Map<String, List<CustomerModel>>>? monthlyCustomers,
    UserModel? userInfo,
    bool? isLoading,

    MenuStatus? menuStatus,
    double? bodyXPosition,
    double? menuXPosition,
  }) {
    return DashBoardState(
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      monthlyCustomers: monthlyCustomers??this.monthlyCustomers,
      userInfo: userInfo?? this.userInfo,
      isLoading: isLoading?? this.isLoading,

      menuStatus: menuStatus ?? this.menuStatus,
      bodyXPosition: bodyXPosition ?? this.bodyXPosition,
      menuXPosition: menuXPosition ?? this.menuXPosition,
    );
  }
}


