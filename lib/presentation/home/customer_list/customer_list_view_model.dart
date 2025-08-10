import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';

import '../../../core/domain/enum/sort_type.dart';
import '../../../core/domain/enum/sort_status.dart';
import '../../../core/presentation/fab/fab_view_model_interface.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/use_case/customer/apply_current_sort_use_case.dart';

class CustomerListViewModel
    with ChangeNotifier
    implements FabViewModelInterface {
  // private 필드로 선언 및 초기화
  SortStatus _sortStatus = SortStatus(type: SortType.name);

  @override
  SortStatus get sortStatus => _sortStatus;

  final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;

  List<CustomerModel> _allCustomers = [];

  bool _showTodoOnly = false;
  bool _todoWithin10DaysOnly = false;

  bool get showTodoOnly => _showTodoOnly;

  bool get todoWithin10DaysOnly => _todoWithin10DaysOnly;

  void updateShowTodoOnly(bool value) {
    _showTodoOnly = value;
    _applyFilterAndSort();
    notifyListeners();
  }

  void updateTodoWithin10DaysOnly(bool value) {
    _todoWithin10DaysOnly = value;
    _applyFilterAndSort();
    notifyListeners();
  }

  bool _isFabVisible = true;

  @override
  bool get isFabVisible => _isFabVisible;

  @override
  void showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      notifyListeners();
    }
  }

  @override
  void hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      notifyListeners();
    }
  }

  Future<void> onMainFabPressedLogic() async {
    // 구현 필요 없음 (빈 구현)
  }

  Future<void> refresh() async {
    await fetchData();
    notifyListeners();
  }

  @override
  Future<void> fetchData({bool force = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final List<CustomerModel> allCustomers = await getIt<CustomerUseCase>()
        .execute(usecase: GetAllDataUseCase(userKey: uid));

    _allCustomers = allCustomers.where((e) => e.policies.isNotEmpty).toList();

    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    final now = DateTime.now();
    var filtered = List<CustomerModel>.from(_allCustomers);

    if (_showTodoOnly) {
      filtered = filtered.where((c) => c.todos.isNotEmpty).toList();

      if (_todoWithin10DaysOnly) {
        final threshold = now.add(const Duration(days: 10));
        filtered =
            filtered.where((c) {
              return c.todos.any(
                (todo) =>
                    todo.dueDate.isAfter(now) &&
                    todo.dueDate.isBefore(threshold),
              );
            }).toList();
      }
    }

    filtered = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(filtered);

    _cachedCustomers.add(List<CustomerModel>.from(filtered));
  }

  void _sort(SortType type) {
    final ascending =
        (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
    _sortStatus = SortStatus(type: type, isAscending: ascending);
    _applyFilterAndSort();
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

  int get todoCount {
    final now = DateTime.now();
    if (_todoWithin10DaysOnly) {
      final threshold = now.add(const Duration(days: 10));
      return _allCustomers.where((c) {
        return c.todos.any(
          (todo) =>
              todo.dueDate.isAfter(now) &&
              todo.dueDate.isBefore(threshold),
        );
      }).length;
    } else {
      return _allCustomers.where((c) => c.todos.isNotEmpty).length;
    }
  }

  int get inactiveCount {
    final thresholdDays = getIt<UserSession>().managePeriodDays;
    final now = DateTime.now();

    return _allCustomers.where((c) {
      final latest = c.histories
          .map((h) => h.contactDate)
          .fold<DateTime?>(
            null,
            (prev, date) => prev == null || date.isAfter(prev) ? date : prev,
          );
      if (latest == null) return true;
      return latest.add(Duration(days: thresholdDays)).isBefore(now);
    }).length;
  }

  void updateCustomerInList(CustomerModel updatedCustomer) {
    final index = _allCustomers.indexWhere(
      (c) => c.userKey == updatedCustomer.userKey,
    );

    if (index != -1) {
      _allCustomers[index] = updatedCustomer;
      _applyFilterAndSort();
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
