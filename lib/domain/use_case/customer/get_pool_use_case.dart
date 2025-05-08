import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../../core/di/setup.dart';
import '../base/base_use_case.dart';

class GetPoolUseCase extends BaseStreamUseCase<CustomerRepository> {
  @override
  Stream call(CustomerRepository repository) {
    return repository.getPools();
  }
}
