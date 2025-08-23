import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/enum/sort_status.dart';
import '../../../core/domain/enum/sort_type.dart';
import '../../../core/presentation/fab/fab_view_model_interface.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';

class ProspectListViewModel
    with ChangeNotifier
    implements FabViewModelInterface {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  List<CustomerModel> allCustomers = [];
  bool _isFabVisible = true;

  @override
  bool get isFabVisible => _isFabVisible;

  bool _isFilterBarExpanded = false;

  bool get isFilterBarExpanded => _isFilterBarExpanded;

  /// 수동 필터 토글 상태
  bool _isFilterBarToggledManually = false;

  bool get isFilterBarToggledManually => _isFilterBarToggledManually;

  /// 최초 자동 처리 여부
  bool _autoHandledOnce = false;

  /// 상령일까지 체크?
  // bool get _allCountsZero =>
  //     todoCount == 0 && urgentCount == 0 && managePeriodCount == 0;
  bool get _allCountsZero =>
      todoCount == 0 && urgentCount == 0;

  void setFilterBarExpanded(bool expanded, {bool manual = false}) {
    _isFilterBarExpanded = expanded;
    if (manual) {
      _isFilterBarToggledManually = true; // ✅ 수동 토글 기록
    }
    notifyListeners();
  }

  /// counts=0일 때는 무조건 닫기
  void resetManualFilterIfEmpty() {
    if (_allCountsZero && _isFilterBarToggledManually) {
      _isFilterBarExpanded = false;
      _isFilterBarToggledManually = false; // 수동 상태 해제
      notifyListeners();
    }
  }

  /// 자동 확장 조건
  bool shouldAutoExpandFilterBar() {
    if (_isFilterBarToggledManually) {
      // ✅ 수동 상태여도 아이템이 전부 0이면 자동으로 닫힘
      if (_allCountsZero) {
        _isFilterBarExpanded = false;
        _isFilterBarToggledManually = false; // 수동 상태 해제
        notifyListeners();
      }
      return false;
    }

    // ✅ 최초 실행일 때만 자동 적용
    if (!_autoHandledOnce) {
      _autoHandledOnce = true;
      return !_allCountsZero;
    }

    return false; // 이후에는 자동 동작 안 함
  }

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

  SortStatus _sortStatus = SortStatus(type: SortType.name, isAscending: true);

  @override
  SortStatus get sortStatus => _sortStatus;

  // 필터 조건
  bool _todoOnly = false;
  bool _inactiveOnly = false;
  bool _urgentOnly = false;
  String _searchText = '';

  void clearCache() {
    _cachedProspects.add([]);
    notifyListeners();
  }

  void updateFilter({
    bool? todoOnly,
    bool? inactiveOnly,
    bool? urgentOnly,
    String? searchText,
  }) {
    if (todoOnly != null) _todoOnly = todoOnly;
    if (inactiveOnly != null) _inactiveOnly = inactiveOnly;
    if (urgentOnly != null) _urgentOnly = urgentOnly;
    if (searchText != null) _searchText = searchText;
    _applyFilterAndSort();
  }

  @override
  Future<void> fetchData({bool force = false}) async {
    final usecase =
        force
            ? GetEditedAllUseCase(userKey: UserSession.userId)
            : GetAllDataUseCase(userKey: UserSession.userId);

    final result = await getIt<CustomerUseCase>().execute(usecase: usecase);
    allCustomers = result;
    _applyFilterAndSort();
    await Future.delayed(const Duration(milliseconds: 10));
  }

  void _applyFilterAndSort() {
    final now = DateTime.now();
    var filtered = allCustomers.where((e) => e.policies.isEmpty).toList();

    if (_searchText.isNotEmpty) {
      filtered = filtered.where((e) => e.name.contains(_searchText)).toList();
    }
    if (_todoOnly) {
      filtered = filtered.where((c) => c.todos.isNotEmpty).toList();
    }
    if (_inactiveOnly) {
      final threshold = getIt<UserSession>().managePeriodDays;
      filtered =
          filtered.where((e) {
            final latest = e.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(
                  null,
                  (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
                );
            return latest == null ||
                latest.add(Duration(days: threshold)).isBefore(now);
          }).toList();
    }
    if (_urgentOnly) {
      final urgentDays = getIt<UserSession>().urgentThresholdDays;
      filtered =
          filtered.where((e) {
            final birth = e.birth;
            if (birth == null) return false;
            final changeDate = getInsuranceAgeChangeDate(birth);
            final diff = changeDate.difference(now).inDays;
            return diff >= 0 && diff <= urgentDays;
          }).toList();
    }

    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(filtered);

    // 수동 상태에서 아이템 모두 0이면 자동으로 닫힘
    resetManualFilterIfEmpty();
    _cachedProspects.add(List.from(sorted));
    notifyListeners();
  }

  int get todoCount =>
      allCustomers
          .where((c) => c.policies.isEmpty && c.todos.isNotEmpty)
          .length;

  int get managePeriodCount {
    final now = DateTime.now();
    final threshold = getIt<UserSession>().managePeriodDays;
    return allCustomers.where((e) {
      if (e.policies.isNotEmpty) return false;
      final latest = e.histories
          .map((h) => h.contactDate)
          .fold<DateTime?>(
            null,
            (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
          );
      return latest == null ||
          latest.add(Duration(days: threshold)).isBefore(now);
    }).length;
  }

  int get urgentCount {
    final now = DateTime.now();
    final urgentDays = getIt<UserSession>().urgentThresholdDays;
    return allCustomers.where((e) {
      if (e.policies.isNotEmpty) return false;
      final birth = e.birth;
      if (birth == null) return false;
      final changeDate = getInsuranceAgeChangeDate(birth);
      final diff = changeDate.difference(now).inDays;
      return diff >= 0 && diff <= urgentDays;
    }).length;
  }

  int get totalProspectCount =>
      allCustomers.where((e) => e.policies.isEmpty).length;

  void addHistoryForCustomer(HistoryModel history, CustomerModel customer) {
    final idx = allCustomers.indexWhere(
      (c) => c.customerKey == customer.customerKey,
    );
    if (idx == -1) return;
    allCustomers[idx].histories.add(history);
    _applyFilterAndSort();
  }

  void _sort(SortType type) {
    final currentList = _cachedProspects.valueOrNull ?? [];
    final ascending =
        (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
    _sortStatus = SortStatus(type: type, isAscending: ascending);
    final sorted = ApplyCurrentSortUseCase(
      isAscending: ascending,
      currentSortType: type,
    ).call(currentList);
    _cachedProspects.add(List.from(sorted));
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

  @override
  bool get hasMainFab => true;

  @override
  bool get hasSmallFab =>true;
}
