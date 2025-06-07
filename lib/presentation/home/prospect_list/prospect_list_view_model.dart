import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/presentation/home/prospect_list/prospect_list_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/use_case/customer/get_prospects_use_case.dart';

class ProspectListViewModel with ChangeNotifier {
  ProspectListState _state = ProspectListState();

  ProspectListState get state => _state;

  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  // 최초 1회
  Future<void> fetchOnce() async {
    if (_state.hasLoadedOnce) return;
    await _fetchData();
    _state = state.copyWith(hasLoadedOnce: true);
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_state.isLoading) return;
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final prospectCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetProspectsUseCase(),
    );

    print('[Fetched prospects]: ${prospectCustomers.length}');

    List<CustomerModel> current = _cachedProspects.value;
    List<CustomerModel> newList = [...prospectCustomers];

    if (_isListChanged(current, newList)) {
      print('추가 확인');
      _cachedProspects.add(newList);
    } else {
      print('추가 반영 안됨');
    }

    _state = state.copyWith(isLoading: false);
    notifyListeners();
  }
  bool _isListChanged(List<CustomerModel> oldList, List<CustomerModel> newList) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].customerKey != newList[i].customerKey) return true;
    }
    return false;}

  @override
  void dispose() {
    _cachedProspects.close();
    super.dispose();
  }
}
