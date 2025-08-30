import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import '../../core/di/setup.dart';
import '../../domain/model/customer_model.dart';
import '../../domain/model/history_model.dart';
import '../../domain/model/policy_model.dart';
import '../../domain/use_case/customer/get_customer_info_use_case.dart';
import '../../domain/use_case/customer/update_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';
import '../../domain/use_case/history/get_histories_use_case.dart';
import '../../domain/use_case/history_use_case.dart';
import '../../domain/use_case/policy/delete_policy_use_case.dart';
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

  Future<void> updatePolicy({
    required String customerKey,
    required PolicyModel policy,
  }) async {
    try {
      await getIt<PolicyUseCase>().execute(
        usecase: UpdatePolicyUseCase(customerKey: customerKey, policy: policy),
      );
      log('[CustomerViewModel] Policy updated: ${policy.policyKey}');
    } catch (e) {
      log('[CustomerViewModel] Failed to update policy: $e');
    }
  }

  Future<void> deletePolicy({
    required String customerKey,
    required String policyKey,
  }) async {
    try {
      await getIt<PolicyUseCase>().execute(
        usecase: DeletePolicyUseCase(
          customerKey: customerKey,
          policyKey: policyKey,
        ),
      );
      log('[CustomerViewModel] Policy deleted: $policyKey');
    } catch (e) {
      log('[CustomerViewModel] Failed to delete policy: $e');
    }
  }

  Future<CustomerModel?> getCustomerInfo({
    required String userKey,
    required String customerKey,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: GetCustomerInfoUseCase(
        userKey: userKey,
        customerKey: customerKey,
      ),
    );
  }

  Future<void> updateMemo({
    required String userKey,
    required String customerKey,
    required String memo,
  }) async {
    try {
      await getIt<CustomerUseCase>().execute(
        usecase: UpdateCustomerUseCase(
          userKey: userKey,
          customerData: {
            keyCustomerKey: customerKey, // 여기 반드시 포함!
            keyCustomerMemo: memo,
          },
        ),
      );
      log('[CustomerViewModel] Memo updated for customer: $customerKey');
    } catch (e) {
      log('[CustomerViewModel] Failed to update memo: $e');
    }
  }
}
