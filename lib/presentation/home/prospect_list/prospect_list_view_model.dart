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
    await _fetchData();
    notifyListeners();
  }

  Future<void> _fetchData() async {
    if (_state.isLoading) return;
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final prospectCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetProspectsUseCase(),
    );

    _cachedProspects.add(prospectCustomers);
    _state = state.copyWith(isLoading: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _cachedProspects.close();
    super.dispose();
  }
}
