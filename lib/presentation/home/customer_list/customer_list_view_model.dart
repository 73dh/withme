import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';
import 'package:withme/presentation/home/customer_list/customer_list_state.dart';

import '../../../domain/domain_import.dart';

class CustomerListViewModel with ChangeNotifier {
  CustomerListState _state = CustomerListState();

  CustomerListState get state => _state;

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
      usecase: GetAllDataUseCase(userKey: FirebaseAuth.instance.currentUser?.uid??''),
    );
    final policyCustomers=allCustomers.where((e)=>e.policies.isNotEmpty).toList();
    _cachedCustomers.add(policyCustomers);
  }

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
