import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

import '../../../core/di/setup.dart';

class AddHistoryUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;
  final String customerKey;
  final Map<String, dynamic> historyData;

  AddHistoryUseCase({
    required this.userKey,
    required this.customerKey,
    required this.historyData,
  });

  @override
  Future call(CustomerRepository repository) async {
    return await repository.addHistory(
      userKey: userKey,
      customerKey: customerKey,
      historyData: historyData,
    );
  }
}
