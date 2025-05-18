import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';

class GetAllUseCase extends BaseStreamUseCase<CustomerRepository> {
  @override
  Stream<List<CustomerModel>> call(CustomerRepository repository) {
    return getIt<CustomerRepository>().getAll();
  }
}
