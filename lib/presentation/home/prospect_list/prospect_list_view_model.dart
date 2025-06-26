import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import 'model/sort_type.dart';

class ProspectListViewModel with ChangeNotifier {
  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
  BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  List<CustomerModel> allCustomers = [];

  SortStatus _sortStatus = SortStatus(SortType.name, true);

  SortStatus get sortStatus => _sortStatus;

  void clearCache() {
    _cachedProspects.add([]);
    notifyListeners(); // 캐시 초기화 시에도 항상 알림
  }

  Future<void> fetchData({bool force = false}) async {
    final result = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: UserSession.userId),
    );

    allCustomers = result;

    final prospects = allCustomers.where((e) => e.policies.isEmpty).toList();
    await Future.delayed(AppDurations.duration100); // UX 안정성을 위한 지연

    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(prospects);

    // 🟢 캐시를 강제로 새 인스턴스로 바꿔 emit
    final newList = List<CustomerModel>.from(sorted);

    _cachedProspects.add(newList);
    notifyListeners();

    debugPrint('[ProspectListViewModel] fetchData completed: ${sorted.length} prospects');
  }

  bool _isListChanged(
      List<CustomerModel> oldList,
      List<CustomerModel> newList,
      ) {
    if (oldList.length != newList.length) return true;

    final oldMap = {for (var e in oldList) e.customerKey: e};

    for (final newItem in newList) {
      final oldItem = oldMap[newItem.customerKey];
      if (oldItem == null) return true; // 새로 추가됨
      if (oldItem.name != newItem.name) return true;
      if (oldItem.birth != newItem.birth) return true;
      if (oldItem.policies.length != newItem.policies.length) return true;
      // 필요한 경우 필드 비교 추가 가능
    }

    return false; // 변경 없음
  }

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

//
// class ProspectListViewModel with ChangeNotifier {
//   final BehaviorSubject<List<CustomerModel>> _cachedProspects =
//       BehaviorSubject.seeded([]);
//
//   Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;
//   late List<CustomerModel> allCustomers;
//
//   SortStatus _sortStatus = SortStatus(SortType.name, true); // 기본값: 이름순 오름차순
//   SortStatus get sortStatus => _sortStatus;
//
//   void clearCache() {
//     _cachedProspects.add([]);
//   }
//
//   Future<void> fetchData({bool force = false}) async {
//     final result = await getIt<CustomerUseCase>().execute(
//       usecase: GetAllDataUseCase(userKey: UserSession.userId),
//     );
//     allCustomers = result;
//
//     final prospectCustomers =
//         allCustomers.where((e) => e.policies.isEmpty).toList();
//     final sorted = ApplyCurrentSortUseCase(
//       isAscending: _sortStatus.isAscending,
//       currentSortType: _sortStatus.type,
//     ).call(prospectCustomers);
//
//     final current = _cachedProspects.valueOrNull ?? [];
//
//     final listChanged = _isListChanged(current, sorted);
//
//     if (force || listChanged) {
//       _cachedProspects.add(List<CustomerModel>.from(sorted));
//       notifyListeners();
//     }
//   }
//
//   bool _isListChanged(
//     List<CustomerModel> oldList,
//     List<CustomerModel> newList,
//   ) {
//     if (oldList.length != newList.length) return true;
//
//     final oldMap = {for (var e in oldList) e.customerKey: e};
//     for (final newItem in newList) {
//       final oldItem = oldMap[newItem.customerKey];
//       if (oldItem == null) return true; // 새로 추가됨
//       if (oldItem.name != newItem.name) return true;
//       if (oldItem.birth != newItem.birth) return true;
//       // 더 비교할 필드 필요시 여기에 추가
//     }
//
//     return false; // 변경 없음
//   }
//
//   @override
//   void dispose() {
//     _cachedProspects.close();
//     super.dispose();
//   }
//
//   /// 공통 정렬 처리 함수
//   void _sort(SortType type) {
//     final currentList = _cachedProspects.valueOrNull;
//     if (currentList != null) {
//       bool ascending =
//           (_sortStatus.type == type) ? !_sortStatus.isAscending : true;
//
//       _sortStatus = SortStatus(type, ascending);
//
//       final sortedList = ApplyCurrentSortUseCase(
//         isAscending: _sortStatus.isAscending,
//         currentSortType: _sortStatus.type,
//       ).call(currentList);
//
//       // 새 인스턴스로 emit
//       _cachedProspects.add(List<CustomerModel>.from(sortedList));
//       notifyListeners();
//     }
//   }
//
//   void sortByName() => _sort(SortType.name);
//
//   void sortByBirth() => _sort(SortType.birth);
//
//   void sortByInsuranceAgeDate() => _sort(SortType.insuredDate);
//
//   void sortByHistoryCount() => _sort(SortType.manage);
// }
