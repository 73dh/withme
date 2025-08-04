import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';
import 'package:withme/presentation/home/customer_list/customer_list_state.dart';

import '../../../core/domain/sort_status.dart';
import '../../../core/presentation/fab/fab_oevelay_manager_mixin.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/use_case/customer/apply_current_sort_use_case.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/presentation/home/customer_list/customer_list_state.dart';
import 'package:withme/core/domain/sort_status.dart';
import 'package:withme/core/presentation/fab/fab_oevelay_manager_mixin.dart';

class CustomerListViewModel with ChangeNotifier implements FabViewModelInterface {
  // 초기 상태
  CustomerListState _state = CustomerListState();
  CustomerListState get state => _state;

  // 정렬 상태
  SortStatus _sortStatus = SortStatus(SortType.name, true);
  @override
  SortStatus get sortStatus => _sortStatus;

  // 캐싱된 고객 목록 스트림
  final BehaviorSubject<List<CustomerModel>> _cachedCustomers = BehaviorSubject.seeded([]);
  Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;

  // 최초 1회 로딩
  Future<void> fetchOnce() async {
    if (_state.hasLoadedOnce) return;
    await _fetchData();
    _state = _state.copyWith(hasLoadedOnce: true);
    notifyListeners();
  }

  @override
  Future<void> fetchData({bool force = false}) async {
    await _fetchData();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetchData();
    notifyListeners();
  }

  Future<void> _fetchData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: uid),
    );

    final policyCustomers = allCustomers.where((e) => e.policies.isNotEmpty).toList();

    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(policyCustomers);

    _cachedCustomers.add(List<CustomerModel>.from(sorted));
  }

  void _sort(SortType type) {
    final currentList = _cachedCustomers.valueOrNull ?? [];
    final ascending = (_sortStatus.type == type) ? !_sortStatus.isAscending : true;

    _sortStatus = SortStatus(type, ascending);

    final sortedList = ApplyCurrentSortUseCase(
      isAscending: ascending,
      currentSortType: type,
    ).call(currentList);

    _cachedCustomers.add(List<CustomerModel>.from(sortedList));
    notifyListeners();
  }

  @override
  void sortByName() => _sort(SortType.name);

  @override
  void sortByBirth() => _sort(SortType.birth);

  @override
  void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);

  @override
  void sortByHistoryCount() => _sort(SortType.manage);

  int get inactiveCount {
    final customers = _cachedCustomers.valueOrNull ?? [];
    final thresholdDays = getIt<UserSession>().managePeriodDays;
    final now = DateTime.now();

    return customers.where((c) {
      final latest = c.histories
          .map((h) => h.contactDate)
          .fold<DateTime?>(null, (prev, date) => prev == null || date.isAfter(prev) ? date : prev);
      if (latest == null) return true;
      return latest.add(Duration(days: thresholdDays)).isBefore(now);
    }).length;
  }

  void updateCustomerInList(CustomerModel updatedCustomer) {
    final currentList = _cachedCustomers.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.userKey == updatedCustomer.userKey);

    if (index != -1) {
      final updatedList = List<CustomerModel>.from(currentList);
      updatedList[index] = updatedCustomer;
      _cachedCustomers.add(updatedList);
      notifyListeners();
    }
  }

  Stream<List<PolicyModel>> getPolicies({required String customerKey}) {
    return getIt<PolicyUseCase>().call(
      usecase: GetPoliciesUseCase(customerKey: customerKey),
    );
  }

  @override
  void dispose() {
    _cachedCustomers.close();
    super.dispose();
  }
}

// class CustomerListViewModel
//     with ChangeNotifier
//     implements FabViewModelInterface {
//   CustomerListState _state = CustomerListState();
//   CustomerListState get state => _state;
//
//   SortStatus _sortStatus = SortStatus(SortType.name, true);
//   @override
//   SortStatus get sortStatus => _sortStatus;
//
//   final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
//   BehaviorSubject.seeded([]);
//   Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;
//
//   Future<void> fetchOnce() async {
//     if (_state.hasLoadedOnce) return;
//     await _fetchData();
//     _state = state.copyWith(hasLoadedOnce: true);
//     notifyListeners();
//   }
//
//   @override
//   Future<void> fetchData({bool force = false}) async {
//     await _fetchData();
//     notifyListeners();
//   }
//
//   Future<void> refresh() async {
//     await _fetchData();
//     notifyListeners();
//   }
//
//   Future<void> _fetchData() async {
//     List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
//       usecase: GetAllDataUseCase(
//         userKey: FirebaseAuth.instance.currentUser?.uid ?? '',
//       ),
//     );
//
//     final policyCustomers =
//     allCustomers.where((e) => e.policies.isNotEmpty).toList();
//
//     final sorted = ApplyCurrentSortUseCase(
//       isAscending: _sortStatus.isAscending,
//       currentSortType: _sortStatus.type,
//     ).call(policyCustomers);
//
//     _cachedCustomers.add(List<CustomerModel>.from(sorted));
//   }
//
//   void _sort(SortType type) {
//     final currentList = _cachedCustomers.valueOrNull ?? [];
//     bool ascending =
//     (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
//
//     _sortStatus = SortStatus(type, ascending);
//
//     final sortedList = ApplyCurrentSortUseCase(
//       isAscending: _sortStatus.isAscending,
//       currentSortType: _sortStatus.type,
//     ).call(currentList);
//
//     _cachedCustomers.add(List<CustomerModel>.from(sortedList));
//     notifyListeners();
//   }
//
//   @override
//   void sortByName() => _sort(SortType.name);
//
//   @override
//   void sortByBirth() => _sort(SortType.birth);
//
//   @override
//   void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);
//
//   @override
//   void sortByHistoryCount() => _sort(SortType.manage);
//
//   int get inactiveCount {
//     final managePeriodDays = getIt<UserSession>().managePeriodDays;
//     final now = DateTime.now();
//
//     final customers = _cachedCustomers.valueOrNull ?? [];
//
//     return customers.where((c) {
//       final latest = c.histories
//           .map((h) => h.contactDate)
//           .fold<DateTime?>(
//         null,
//             (prev, date) => prev == null || date.isAfter(prev) ? date : prev,
//       );
//       if (latest == null) return true;
//       return latest.add(Duration(days: managePeriodDays)).isBefore(now);
//     }).length;
//   }
//
//   void updateCustomerInList(CustomerModel updatedCustomer) {
//     final currentList = _cachedCustomers.valueOrNull ?? [];
//     final index = currentList.indexWhere((c) => c.userKey == updatedCustomer.userKey);
//
//     if (index != -1) {
//       final updatedList = List<CustomerModel>.from(currentList);
//       updatedList[index] = updatedCustomer;
//       _cachedCustomers.add(updatedList);
//       notifyListeners();
//     }
//   }
//
//   @override
//   void dispose() {
//     _cachedCustomers.close();
//     super.dispose();
//   }
//
//   Stream getPolicies({required String customerKey}) {
//     return getIt<PolicyUseCase>().call(
//       usecase: GetPoliciesUseCase(customerKey: customerKey),
//     );
//   }
// }

//
// class CustomerListViewModel
//     with ChangeNotifier
//     implements FabViewModelInterface {
//   CustomerListState _state = CustomerListState();
//
//   CustomerListState get state => _state;
//
//   SortStatus _sortStatus = SortStatus(SortType.name, true);
//
//   @override
//   SortStatus get sortStatus => _sortStatus;
//
//   final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
//       BehaviorSubject.seeded([]);
//
//   Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;
//
//   Future<void> fetchOnce() async {
//     if (_state.hasLoadedOnce) return;
//     await _fetchData();
//     _state = state.copyWith(hasLoadedOnce: true);
//     notifyListeners();
//   }
//
//   @override
//   Future<void> fetchData({bool force = false}) async {
//     await _fetchData();
//     notifyListeners();
//   }
//
//   Future<void> refresh() async {
//     await _fetchData();
//     notifyListeners();
//   }
//
//   Future<void> _fetchData() async {
//     List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
//       usecase: GetAllDataUseCase(
//         userKey: FirebaseAuth.instance.currentUser?.uid ?? '',
//       ),
//     );
//
//     final policyCustomers =
//         allCustomers.where((e) => e.policies.isNotEmpty).toList();
//
//     final sorted = ApplyCurrentSortUseCase(
//       isAscending: _sortStatus.isAscending,
//       currentSortType: _sortStatus.type,
//     ).call(policyCustomers);
//
//     _cachedCustomers.add(List<CustomerModel>.from(sorted));
//   }
//
//   void _sort(SortType type) {
//     final currentList = _cachedCustomers.valueOrNull ?? [];
//     bool ascending =
//         (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
//
//     _sortStatus = SortStatus(type, ascending);
//
//     final sortedList = ApplyCurrentSortUseCase(
//       isAscending: _sortStatus.isAscending,
//       currentSortType: _sortStatus.type,
//     ).call(currentList);
//
//     _cachedCustomers.add(List<CustomerModel>.from(sortedList));
//     notifyListeners();
//   }
//
//   @override
//   void sortByName() => _sort(SortType.name);
//
//   @override
//   void sortByBirth() => _sort(SortType.birth);
//
//   @override
//   void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);
//
//   @override
//   void sortByHistoryCount() => _sort(SortType.manage);
//
//   int get inactiveCount {
//     final managePeriodDays = getIt<UserSession>().managePeriodDays;
//     final now = DateTime.now();
//
//     final customers = _cachedCustomers.valueOrNull ?? [];
//
//     return customers.where((c) {
//       final latest = c.histories
//           .map((h) => h.contactDate)
//           .fold<DateTime?>(
//             null,
//             (prev, date) => prev == null || date.isAfter(prev) ? date : prev,
//           );
//       if (latest == null) return true;
//       return latest.add(Duration(days: managePeriodDays)).isBefore(now);
//     }).length;
//   }
//
//   @override
//   void dispose() {
//     _cachedCustomers.close();
//     super.dispose();
//   }
//
//   Stream getPolicies({required String customerKey}) {
//     return getIt<PolicyUseCase>().call(
//       usecase: GetPoliciesUseCase(customerKey: customerKey),
//     );
//   }
// }
