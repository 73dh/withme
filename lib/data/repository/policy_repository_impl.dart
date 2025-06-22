import 'package:withme/core/utils/transformers/transformers.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/repository/policy_repository.dart';

import '../../domain/model/policy_model.dart';

class PolicyRepositoryImpl with Transformers implements PolicyRepository {
  final FBase fBase;

  PolicyRepositoryImpl({required this.fBase});

  @override
  Stream<List<PolicyModel>> fetchPolicies({required String customerKey}) {
    return fBase.fetchPolicies(customerKey: customerKey).transform(toPolicies);
  }

  // @override
  // Future<List<PolicyModel>> getPolicies({required String customerKey}) async {
  //   return (await fBase.getPolicies(
  //     customerKey: customerKey,
  //   )).docs.map((e) => PolicyModel.fromSnapshot(e)).toList();
  // }
  @override
  Future<List<PolicyModel>> getPolicies({required String customerKey}) async {
    final snapshot = await fBase.fetchPolicies(customerKey: customerKey).first;

    // snapshot.docs가 DocumentSnapshot의 리스트라면 다음과 같이 처리
    return snapshot.docs.map((doc) => PolicyModel.fromSnapshot(doc)).toList();
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

  @override
  Future<void> changePolicyState({
    required String customerKey,
    required String policyKey,
    required String policyState,
  })async {
    return await fBase.changePolicyState(
      customerKey: customerKey,
      policyKey: policyKey,
      policyState: policyState,
    );
  }
}
