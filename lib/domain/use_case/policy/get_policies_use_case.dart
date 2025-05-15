import 'package:withme/data/repository/policy_repository_impl.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/presentation/policy/policy_view_model.dart';

import '../../repository/policy_repository.dart';

class GetPoliciesUseCase implements BaseStreamUseCase<PolicyRepository>{
  final String customerKey;

  GetPoliciesUseCase({required this.customerKey});
  @override
  Stream call(PolicyRepository repository) {
   return repository.fetchPolicies(customerKey: customerKey);
  }

}