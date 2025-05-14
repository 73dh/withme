import 'package:withme/core/utils/transformers.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/repository/policy_repository.dart';

import '../../domain/model/policy_model.dart';

class PolicyRepositoryImpl with Transformers implements PolicyRepository {
  final FBase fBase;

  PolicyRepositoryImpl({required this.fBase});

  // @override
  // Stream<List<PolicyModel>> fetchPolicies({required String customerKey}) {
  //   return fBase.fetchPolicies(customerKey: customerKey).transform(toPolicies);
  // }

  @override
  Future<List<PolicyModel>> getPolicies({required String customerKey}) async {
    return (await fBase.getPolicies(
      customerKey: customerKey,
    )).docs.map((e) => PolicyModel.fromSnapshot(e)).toList();
  }

  @override
  Future<void> addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  }) async {
    return await fBase.addPolicy(
      userKey: userKey,
      customerKey: customerKey,
      policyData: policyData,
    );
  }
}
