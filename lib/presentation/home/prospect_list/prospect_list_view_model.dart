import 'dart:async';

import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/domain/use_case/history_use_case.dart';
import 'package:withme/presentation/home/prospect_list/prospect_list_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/use_case/customer/get_prospect_use_case.dart';
import '../../../domain/use_case/history/get_histories_use_case.dart';
import 'package:rxdart/rxdart.dart';

class ProspectListViewModel with ChangeNotifier {
  ProspectListState _state = ProspectListState();

  ProspectListState get state => _state;

  Future<void> fetchOnce() async {
    if (_state.hasLoadedOnce) return;
    await _fetchData();
    _state = state.copyWith(hasLoadedOnce: true);
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_state.isLoading) return;
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final prospectCustomers =
        await getIt<CustomerUseCase>()
            .call<List<CustomerModel>>(usecase: GetProspectUseCase())
            .first;
    _state = state.copyWith(
      cachedProspects: prospectCustomers,
      isLoading: false,
    );
    notifyListeners();
  }

  // final BehaviorSubject<List<CustomerModel>> _prospectSubject =
  //     BehaviorSubject.seeded([]);
  //
  // Stream<List<CustomerModel>> get prospectsStream => _prospectSubject.stream;
  //
  // bool _hasLoadedOnce = false;
  // bool _isLoading = false;
  //
  // get isLoading => _isLoading;
  //
  // /// 최초 1회 로딩만 수행
  // Future<void> fetchOnce() async {
  //   if (_hasLoadedOnce) return;
  //   await _fetchData();
  //   _hasLoadedOnce = true;
  // }
  //
  // /// 새로고침 (수동)
  // Future<void> refresh() async {
  //   await _fetchData();
  // }
  //
  // /// 실제 데이터 로딩 함수
  // Future<void> _fetchData() async {
  //   if (_isLoading) return;
  //   _isLoading = true;
  //
  //   try {
  //     final prospectCustomers =
  //         await getIt<CustomerUseCase>()
  //             .call<List<CustomerModel>>(usecase: GetProspectUseCase())
  //             .first;
  //     _prospectSubject.add(prospectCustomers);
  //   } catch (e, st) {
  //     _prospectSubject.addError(e, st);
  //   } finally {
  //     _isLoading = false;
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   _prospectSubject.close();
  //   super.dispose();
  // }
}
