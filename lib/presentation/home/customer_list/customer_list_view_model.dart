import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';

import '../../../core/domain/enum/sort_status.dart';
import '../../../core/domain/enum/sort_type.dart';
import '../../../core/presentation/fab/fab_view_model_interface.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';

class CustomerListViewModel
    with ChangeNotifier
    implements FabViewModelInterface {
  // ================= Stream =================
  final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;

  List<CustomerModel> _allCustomers = [];

  // ================= FAB =================
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

  Future<void> onMainFabPressedLogic() async {}

  // ================= FilterBar =================
  bool _isFilterBarExpanded = false;

  bool get isFilterBarExpanded => _isFilterBarExpanded;

  bool _isFilterBarToggledManually = false;

  bool get isFilterBarToggledManually => _isFilterBarToggledManually;

  bool _autoHandledOnce = false;

  void setFilterBarExpanded(bool expanded, {bool manual = false}) {
    _isFilterBarExpanded = expanded;
    if (manual) _isFilterBarToggledManually = true;
    notifyListeners();
  }

  bool get _allCountsZero => todoCount == 0 && managePeriodCount == 0;

  // ================= 필터 상태 =================
  bool _showTodoOnly = false;
  bool _showInactiveOnly = false;
  bool _showUrgentOnly = false;
  bool _showInsuranceAgeUrgentOnly = false;

  bool get showTodoOnly => _showTodoOnly;

  bool get showInactiveOnly => _showInactiveOnly;

  bool get showUrgentOnly => _showUrgentOnly;

  bool get showInsuranceAgeUrgentOnly => _showInsuranceAgeUrgentOnly;

  void updateFilter({
    bool? todoOnly,
    bool? inactiveOnly,
    bool? urgentOnly,
    bool? insuranceAgeUrgentOnly,
  }) {
    if (todoOnly != null) _showTodoOnly = todoOnly;
    if (inactiveOnly != null) _showInactiveOnly = inactiveOnly;
    if (urgentOnly != null) _showUrgentOnly = urgentOnly;
    if (insuranceAgeUrgentOnly != null) {
      _showInsuranceAgeUrgentOnly = insuranceAgeUrgentOnly;
    }
    _applyFilterAndSort();
  }

  // ================= 정렬 =================
  SortStatus _sortStatus = SortStatus(type: SortType.name, isAscending: true);

  @override
  SortStatus get sortStatus => _sortStatus;

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

  // ================= 데이터 로드 =================
  @override
  Future<void> fetchData({bool force = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final List<CustomerModel> allCustomers = await getIt<CustomerUseCase>()
        .execute(usecase: GetAllDataUseCase(userKey: uid));

    _allCustomers = allCustomers.where((c) => c.policies.isNotEmpty).toList();
    _applyFilterAndSort();
  }

  Future<void> refresh() async => fetchData(force: true);

  // ================= 필터 + 정렬 + filterBar 상태 =================
  void _applyFilterAndSort() {
    final now = DateTime.now();
    var filtered = List<CustomerModel>.from(_allCustomers);

    if (_showTodoOnly) {
      filtered = filtered.where((c) => c.todos.isNotEmpty).toList();
    }
    if (_showInactiveOnly) {
      final threshold = getIt<UserSession>().managePeriodDays;
      filtered =
          filtered.where((c) {
            final latest = c.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(
                  null,
                  (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
                );
            return latest == null ||
                latest.add(Duration(days: threshold)).isBefore(now);
          }).toList();
    }
    if (_showUrgentOnly) {
      final urgentDays = getIt<UserSession>().urgentThresholdDays;
      filtered =
          filtered.where((c) {
            final latest = c.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(
                  null,
                  (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
                );
            return latest != null &&
                latest.add(Duration(days: urgentDays)).isBefore(now);
          }).toList();
    }
    if (_showInsuranceAgeUrgentOnly) {
      final urgentDays = getIt<UserSession>().urgentThresholdDays;
      filtered =
          filtered.where((c) {
            final birth = c.birth;
            if (birth == null) return false;
            final changeDate = getInsuranceAgeChangeDate(birth);
            final diff = changeDate.difference(now).inDays;
            return diff >= 0 && diff <= urgentDays;
          }).toList();
    }

    filtered = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(filtered);

    // ================= filterBar 상태 처리 =================
    if (_allCountsZero) {
      _isFilterBarExpanded = false;
      _isFilterBarToggledManually = false;
    } else {
      if (!_autoHandledOnce) {
        _isFilterBarExpanded = true;
        _autoHandledOnce = true;
      }
    }

    _cachedCustomers.add(List<CustomerModel>.from(filtered));
    notifyListeners();
  }

  // ================= 필터 카운트 =================
  int get todoCount => _allCustomers.where((c) => c.todos.isNotEmpty).length;

  int get managePeriodCount {
    final now = DateTime.now();
    final threshold = getIt<UserSession>().managePeriodDays;
    return _allCustomers.where((c) {
      final latest = c.histories
          .map((h) => h.contactDate)
          .fold<DateTime?>(
            null,
            (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
          );
      return latest == null ||
          latest.add(Duration(days: threshold)).isBefore(now);
    }).length;
  }

  int get insuranceAgeUrgentCount {
    final now = DateTime.now();
    final urgentDays = getIt<UserSession>().urgentThresholdDays;
    return _allCustomers.where((c) {
      final birth = c.birth;
      if (birth == null) return false;
      final changeDate = getInsuranceAgeChangeDate(birth);
      final diff = changeDate.difference(now).inDays;
      return diff >= 0 && diff <= urgentDays;
    }).length;
  }

  // ================= 계약 관련 =================
  Stream<List<PolicyModel>> getPolicies({required String customerKey}) {
    return getIt<PolicyUseCase>().call(
      usecase: GetPoliciesUseCase(customerKey: customerKey),
    );
  }

  // ================= 고객 업데이트 =================
  void updateCustomerInList(CustomerModel updatedCustomer) {
    final index = _allCustomers.indexWhere(
      (c) => c.userKey == updatedCustomer.userKey,
    );
    if (index != -1) {
      _allCustomers[index] = updatedCustomer;
      _applyFilterAndSort();
    }
  }

  @override
  void dispose() {
    _cachedCustomers.close();
    super.dispose();
  }

  @override
  bool get hasMainFab => false;

  @override
  bool get hasSmallFab => true;
}
