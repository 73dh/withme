import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';
import 'package:withme/presentation/home/customer_list/customer_list_state.dart';

import '../../../core/domain/sort_status.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/use_case/customer/apply_current_sort_use_case.dart';

class CustomerListViewModel with ChangeNotifier {
  CustomerListState _state = CustomerListState();

  CustomerListState get state => _state;

  SortStatus _sortStatus = SortStatus(SortType.name, true);

  SortStatus get sortStatus => _sortStatus;


  final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
      BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get cachedCustomers => _cachedCustomers.stream;

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
    List<CustomerModel> allCustomers = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(
        userKey: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
    );
    final policyCustomers =
        allCustomers.where((e) => e.policies.isNotEmpty).toList();

    final sorted = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(policyCustomers);

    // _cachedCustomers.add(policyCustomers);
    _cachedCustomers.add(List<CustomerModel>.from(sorted));
  }

  void _sort(SortType type) {
    final currentList = _cachedCustomers.valueOrNull ?? [];
    bool ascending =
    (_sortStatus.type == type) ? !_sortStatus.isAscending : true;

    _sortStatus = SortStatus(type, ascending);

    final sortedList = ApplyCurrentSortUseCase(
      isAscending: _sortStatus.isAscending,
      currentSortType: _sortStatus.type,
    ).call(currentList);

    _cachedCustomers.add(List<CustomerModel>.from(sortedList));
    notifyListeners();
  }

  void sortByName() => _sort(SortType.name);

  void sortByBirth() => _sort(SortType.birth);




  @override
  void dispose() {
    _cachedCustomers.close();
    super.dispose();
  }

  Stream getPolicies({required String customerKey}) {
    return getIt<PolicyUseCase>().call(
      usecase: GetPoliciesUseCase(customerKey: customerKey),
    );
  }
}
