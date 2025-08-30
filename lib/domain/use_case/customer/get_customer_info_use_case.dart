import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';

class GetCustomerInfoUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;
  final String customerKey;

  GetCustomerInfoUseCase({
    required this.userKey,
    required this.customerKey,
  });

  @override
  Future<CustomerModel?> call(CustomerRepository repository) async {
    final customerRepository = getIt<CustomerRepository>();

    // 단일 고객 정보만 가져오기
    return await customerRepository.getCustomerInfo(
      userKey: userKey,
      customerKey: customerKey,
    );
  }
}
