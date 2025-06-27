import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';

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
    List<CustomerModel> result;
    if (force) {
      result = await getIt<CustomerUseCase>().execute(
        usecase: GetEditedAllUseCase(userKey: UserSession.userId),
      );
      debugPrint(
        '[ProspectListViewModel] fetchData from SERVER: ${result.length}',
      );
      print('데이터 갯수: ${result.length}');
    } else {
      result = await getIt<CustomerUseCase>().execute(
        usecase: GetAllDataUseCase(userKey: UserSession.userId),
      );
      debugPrint(
        '[ProspectListViewModel] fetchData from CACHE/STREAM: ${result.length}',
      );
    }

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

    debugPrint(
      '[ProspectListViewModel] fetchData completed: ${sorted.length} prospects',
    );
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

