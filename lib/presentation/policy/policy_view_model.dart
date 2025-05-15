import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/policy/add_policy_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';

import '../../core/di/setup.dart';

class PolicyViewModel with ChangeNotifier {
  Future addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  }) async {
    return await getIt<PolicyUseCase>().execute(
      usecase: AddPolicyUseCase(
        userKey: userKey,
        customerKey: customerKey,
        policyData: policyData,
      ),
    );
  }
}
