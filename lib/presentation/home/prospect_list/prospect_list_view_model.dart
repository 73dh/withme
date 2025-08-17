import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/enum/sort_type.dart';
import '../../../core/domain/enum/sort_status.dart';
import '../../../core/presentation/fab/fab_view_model_interface.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';



class ProspectListViewModel
    with ChangeNotifier
    implements FabViewModelInterface {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  List<CustomerModel> allCustomers = [];
  bool _isFabVisible = true; // 기본값 설정

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
    debugPrint(
      '[ProspectListViewModel] fetchData (${force ? "SERVER" : "CACHE"}): ${result.length}',
    );

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
      filtered =
          filtered.where((customer) => customer.todos.isNotEmpty).toList();
    }

    if (_inactiveOnly) {
      final threshold = getIt<UserSession>().managePeriodDays;
      filtered =
          filtered.where((e) {
            final latest = e.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(
                  null,
                  (prev, date) =>
                      prev == null || date.isAfter(prev) ? date : prev,
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

    // 정렬 적용: _sortStatus가 null일 수 없으니 바로 적용
    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(filtered);

    _cachedProspects.add(List.from(sorted));

    notifyListeners();
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

  int get todoCount {
    return allCustomers
        .where((customer) => customer.policies.isEmpty) // prospect만
        .where((customer) => customer.todos.isNotEmpty) // todo가 있는 경우만
        .length;
  }

  int get inactiveCount {
    final now = DateTime.now();
    final threshold = getIt<UserSession>().managePeriodDays;

    return allCustomers.where((e) {
      if (e.policies.isNotEmpty) return false;
      final latest = e.histories
          .map((h) => h.contactDate)
          .fold<DateTime?>(
            null,
            (prev, date) => prev == null || date.isAfter(prev) ? date : prev,
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
}
