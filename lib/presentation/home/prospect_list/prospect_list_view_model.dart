import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
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


    List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: UserSession.userId),
    );
    await Future.delayed(AppDurations.duration100);

    final prospectCustomers =
    allCustomers.where((e) => e.policies.isEmpty).toList();

    debugPrint('[Fetched prospects]: ${prospectCustomers.length}');

    List<CustomerModel> current = _cachedProspects.value;
    bool listChanged = _isListChanged(current, prospectCustomers);
    debugPrint('force: $force, listChanged: $listChanged');

    if (force || _isListChanged(current, prospectCustomers)) {
      final sorted = ApplyCurrentSortUseCase(
        isAscending: _sortStatus.isAscending,
        currentSortType: _sortStatus.type,
      ).call(prospectCustomers);

      debugPrint('Adding sorted list with length: ${sorted.length}');
      _cachedProspects.add(List<CustomerModel>.from(sorted));
      notifyListeners();
    } else {
      debugPrint('No update needed, skipping add.');
    }
    // if (force || _isListChanged(current, prospectCustomers)) {
    //   final sorted = ApplyCurrentSortUseCase(
    //     isAscending: _sortStatus.isAscending,
    //     currentSortType: _sortStatus.type,
    //   ).call(prospectCustomers);
    //
    //   _cachedProspects.add([...sorted]);
    //   notifyListeners();
    // }
  }

  bool _isListChanged(List<CustomerModel> oldList, List<CustomerModel> newList) {
    if (oldList.length != newList.length) return true;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].customerKey != newList[i].customerKey) return true;

      // 원하는 필드 몇 개 더 비교 (예: 이름, 생일 등)
      if (oldList[i].name != newList[i].name) return true;
      if (oldList[i].birth != newList[i].birth) return true;
      // 필요시 더 비교
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
