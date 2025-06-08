import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/presentation/home/prospect_list/prospect_list_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';

class ProspectListViewModel with ChangeNotifier {
  ProspectListState _state = ProspectListState();

  ProspectListState get state => _state;

  final BehaviorSubject<List<CustomerModel>> _cachedProspects =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedProspects => _cachedProspects.stream;

  Future<void>  fetchData({bool force = false}) => _fetchData(force);

  // 최초 1회
  // Future<void> fetchOnce() async {
  //   if (_state.hasLoadedOnce) return;
  //   await _fetchData();
  //   _state = state.copyWith(hasLoadedOnce: true);
  //   notifyListeners();
  // }

  // Future<void> refresh() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   await _fetchData();
  // }

  Future<void> _fetchData(bool force) async {
    await Future.delayed(const Duration(seconds: 1));
    // final prospectCustomers = await getIt<CustomerUseCase>().execute(
    //   usecase: GetProspectsUseCase(),
    // );
    //

    List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(),
    );
final prospectCustomers=allCustomers.where((e)=>e.policies.isEmpty).toList();

    print('[Fetched prospects]: ${prospectCustomers.length}');

    List<CustomerModel> current = _cachedProspects.value;

    if (force || _isListChanged(current, prospectCustomers)) {
      _cachedProspects.add(prospectCustomers);
    }
  }

  // Future<void> _fetchData() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   final prospectCustomers = await getIt<CustomerUseCase>().execute(
  //     usecase: GetProspectsUseCase(),
  //   );
  //
  //   print('[Fetched prospects]: ${prospectCustomers.length}');
  //
  //   List<CustomerModel> current = _cachedProspects.value;
  //   List<CustomerModel> newList = [...prospectCustomers];
  //
  //   if (_isListChanged(current, newList)) {
  //     print('추가 확인');
  //     _cachedProspects.add(newList);
  //   } else {
  //     print('추가 반영 안됨');
  //   }
  // }

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
}
