import 'package:withme/domain/repository/repository.dart';

import '../model/policy_model.dart';

abstract interface class PolicyRepository implements Repository {
  Stream<List<PolicyModel>> fetchPolicies({required String customerKey});

  Future<List<PolicyModel>> getPolicies({required String customerKey});

  Future<void> addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  });
}
