import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import 'model/sort_type.dart';

class ProspectListViewModel with ChangeNotifier {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
  BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  SortStatus _sortStatus =  SortStatus(SortType.name, true); // 기본값: 이름순 오름차순
  SortStatus get sortStatus => _sortStatus;


  void clearCache() {
    _cachedProspects.add([]);
  }

  Future<void> fetchData({bool force = false}) async {

    await Future.delayed(AppDurations.duration100);

    List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: 'dCQwqcdN19RWQtv5dbLV0hx1v7H3'),
    );

    final prospectCustomers =
    allCustomers.where((e) => e.policies.isEmpty).toList();

    debugPrint('[Fetched prospects]: ${prospectCustomers.length}');

    List<CustomerModel> current = _cachedProspects.value;

    if (force || _isListChanged(current, prospectCustomers)) {
      final sorted = ApplyCurrentSortUseCase(
        isAscending: _sortStatus.isAscending,
        currentSortType: _sortStatus.type,
      ).call(prospectCustomers);

      _cachedProspects.add(sorted);
      notifyListeners();
    }
  }

  bool _isListChanged(List<CustomerModel> oldList, List<CustomerModel> newList) {
    if (oldList.length != newList.length) return true;

    final oldKeys = oldList.map((e) => e.customerKey).toSet();
    final newKeys = newList.map((e) => e.customerKey).toSet();

    return !oldKeys.containsAll(newKeys) || !newKeys.containsAll(oldKeys);
  }


  @override
  void dispose() {
    _cachedProspects.close();
    super.dispose();
  }

  /// 공통 정렬 처리 함수
  void _sort(SortType type) {
    final currentList = _cachedProspects.valueOrNull;
    if (currentList != null) {
      // 정렬 타입이 같으면 방향만 토글, 다르면 새로운 타입 + 오름차순
      bool ascending = (_sortStatus.type == type)
          ? !_sortStatus.isAscending
          : true;

      _sortStatus = SortStatus(type, ascending);

      final sortedList = ApplyCurrentSortUseCase(
        isAscending: _sortStatus.isAscending,
        currentSortType: _sortStatus.type,
      ).call(currentList);

      _cachedProspects.add(sortedList);
      notifyListeners();
    }
  }

  void sortByName() => _sort(SortType.name);
  void sortByBirth() => _sort(SortType.birth);
  void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);
  void sortByHistoryCount() => _sort(SortType.manage);
}
