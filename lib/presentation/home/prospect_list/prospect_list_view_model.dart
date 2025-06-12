import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import 'enum/sort_type.dart';

class ProspectListViewModel with ChangeNotifier {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
  BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  bool _isAscending = true;
  SortType? _currentSortType;

  SortType? get currentSortType => _currentSortType;

  void clearCache() {
    _cachedProspects.add([]);
  }

  Future<void> fetchData({bool force = false}) async {
    await Future.delayed(AppDurations.duration100);

    List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(),
    );

    final prospectCustomers =
    allCustomers.where((e) => e.policies.isEmpty).toList();

    debugPrint('[Fetched prospects]: ${prospectCustomers.length}');

    List<CustomerModel> current = _cachedProspects.value;

    if (force || _isListChanged(current, prospectCustomers)) {
      _currentSortType ??=SortType.name;
      final sorted = ApplyCurrentSortUseCase(
        isAscending: _isAscending,
        currentSortType: _currentSortType!,
      ).call(prospectCustomers);

      _cachedProspects.add(sorted);
      notifyListeners();
    }
  }

  bool _isListChanged(
      List<CustomerModel> oldList,
      List<CustomerModel> newList,
      ) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].customerKey != newList[i].customerKey) return true;
    }
    return false;
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
      _isAscending = !_isAscending;
      _currentSortType = type;

      final sortedList = ApplyCurrentSortUseCase(
        isAscending: _isAscending,
        currentSortType: _currentSortType!,
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
