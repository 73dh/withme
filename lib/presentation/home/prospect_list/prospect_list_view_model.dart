import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../data/data_source/remote/fbase.dart';
import '../../../domain/domain_import.dart';
import '../../../core/domain/sort_status.dart';

class ProspectListViewModel with ChangeNotifier {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  List<CustomerModel> allCustomers = [];

  SortStatus _sortStatus = SortStatus(SortType.name, true);

  SortStatus get sortStatus => _sortStatus;

  // 🔍 필터 조건들
  bool _inactiveOnly = false;
  bool _urgentOnly = false;
  String _searchText = '';

  void clearCache() {
    _cachedProspects.add([]);
    notifyListeners(); // 캐시 초기화 시에도 항상 알림
  }


  /// ✅ 외부에서 필터 상태 업데이트
  void updateFilter({
    bool? inactiveOnly,
    bool? urgentOnly,
    String? searchText,
  }) {
    if (inactiveOnly != null) _inactiveOnly = inactiveOnly;
    if (urgentOnly != null) _urgentOnly = urgentOnly;
    if (searchText != null) _searchText = searchText;

    _applyFilterAndSort();
  }
  Future<void> fetchData({bool force = false}) async {
    final usecase =
        force
            ? GetEditedAllUseCase(userKey: UserSession.userId)
            : GetAllDataUseCase(userKey: UserSession.userId);

    final List<CustomerModel> result = await getIt<CustomerUseCase>().execute(
      usecase: usecase,
    );
    debugPrint(
      '[ProspectListViewModel] fetchData (${force ? "SERVER" : "CACHE"}): ${result.length}',
    );

    allCustomers = result;

    // final List<CustomerModel> prospects =
    //     result.where((e) => e.policies.isEmpty).toList();

    _applyFilterAndSort();
    await Future.delayed(AppDurations.duration100); // UX 안정성을 위한 지연
    //
    // final sorted = ApplyCurrentSortUseCase(
    //   isAscending: _sortStatus.isAscending,
    //   currentSortType: _sortStatus.type,
    // ).call(prospects);

    // _cachedProspects.add(List<CustomerModel>.from(sorted)); // 새 인스턴스로 emit
    // notifyListeners();
  }

  void _applyFilterAndSort() {
    final now = DateTime.now();

    var filtered = allCustomers.where((e) => e.policies.isEmpty).toList();

    // 🔍 검색어
    if (_searchText.isNotEmpty) {
      filtered = filtered.where((e) => e.name.contains(_searchText)).toList();
    }

    // ⏳ 관리기간 초과 필터
    if (_inactiveOnly) {
      final threshold = getIt<UserSession>().managePeriodDays;

      filtered = filtered.where((e) {
        final latestDate = e.histories
            .map((h) => h.contactDate)
            .fold<DateTime?>(null, (prev, date) {
          if (prev == null) return date;
          return date.isAfter(prev) ? date : prev;
        });

        if (latestDate == null) return true;
        return latestDate.add(Duration(days: threshold)).isBefore(now);
      }).toList();
    }

    // ⏰ 상령일 임박 필터
    if (_urgentOnly) {
      final urgentDays = getIt<UserSession>().urgentThresholdDays;

      filtered = filtered.where((e) {
        final birth = e.birth;
        if (birth == null) return false;

        final insuranceAgeChangeDate = getInsuranceAgeChangeDate(birth);
        final diff = insuranceAgeChangeDate.difference(now).inDays;
        return diff <= urgentDays;
      }).toList();
    }

    // 🔁 정렬 적용
    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(filtered);

    _cachedProspects.add(List<CustomerModel>.from(sorted));
    notifyListeners();
  }

  // void _sort(SortType type) {
  //   final currentList = _cachedProspects.valueOrNull ?? [];
  //   bool ascending =
  //   (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
  //
  //   _sortStatus = SortStatus(type, ascending);
  //
  //   final sortedList = ApplyCurrentSortUseCase(
  //     isAscending: _sortStatus.isAscending,
  //     currentSortType: _sortStatus.type,
  //   ).call(currentList);
  //
  //   _cachedProspects.add(List<CustomerModel>.from(sortedList));
  //   notifyListeners();
  // }

  @override
  void dispose() {
    _cachedProspects.close();
    super.dispose();
  }

  void _sort(SortType type) {
    final currentList = _cachedProspects.valueOrNull ?? [];
    bool ascending =
        (_sortStatus.type == type) ? !_sortStatus.isAscending : true;

    _sortStatus = SortStatus(type, ascending);

    final sortedList = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(currentList);

    _cachedProspects.add(List<CustomerModel>.from(sortedList));
    notifyListeners();
  }

  void sortByName() => _sort(SortType.name);

  void sortByBirth() => _sort(SortType.birth);

  void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);

  void sortByHistoryCount() => _sort(SortType.manage);


}
