import 'package:withme/domain/repository/policy_repository.dart';

import 'base/base_stream_use_case.dart';
import 'base/base_use_case.dart';

class PolicyUseCase{
  final PolicyRepository _policyRepository;

  PolicyUseCase({required PolicyRepository policyRepository}) : _policyRepository = policyRepository;
  Future execute<T>({required BaseUseCase usecase}) async {
    return  usecase(_policyRepository);
  }

  Stream<R> call<R>({required BaseStreamUseCase<R,PolicyRepository> usecase}){
    return usecase(_policyRepository);
  }
}