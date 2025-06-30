import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/di/setup.dart';
import '../../domain/model/history_model.dart';
import '../../domain/model/policy_model.dart';
import '../../domain/use_case/history/get_histories_use_case.dart';
import '../../domain/use_case/history_use_case.dart';
import '../../domain/use_case/policy/get_policies_use_case.dart';
import '../../domain/use_case/policy/update_policy_use_case.dart';
import '../../domain/use_case/policy_use_case.dart';

class CustomerViewModel with ChangeNotifier {
  Stream<List<HistoryModel>> getHistories(String userKey, String customerKey) {
    return getIt<HistoryUseCase>().call(
      usecase: GetHistoriesUseCase(userKey: userKey, customerKey: customerKey),
    );
  }

  Stream<List<PolicyModel>> getPolicies(String customerKey) {
    return getIt<PolicyUseCase>().call(
      usecase: GetPoliciesUseCase(customerKey: customerKey),
    );
  }

  Future<void> updatePolicy({required String customerKey, required PolicyModel policy}) async {
    try {
      await getIt<PolicyUseCase>().execute(usecase: UpdatePolicyUseCase(customerKey: customerKey, policy: policy));
      log('[CustomerViewModel] Policy updated: ${policy.policyKey}');
    } catch (e) {
      log('[CustomerViewModel] Failed to update policy: $e');
    }
  }
}
