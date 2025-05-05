import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../core/di/setup.dart';
import '../../data/data_source/remote/fbase.dart';
import '../model/customer.dart';

class GetPoolUseCase {
  static Future execute() async {
    final customers =
        await getIt<CustomerRepository>().getCustomers();

    customers.sort((a, b) => a.registeredDate.compareTo(b.registeredDate));

    final isNotPolicies =
        customers.where((customer) => customer.isPolicy == false).toList();
    return isNotPolicies;
  }
}
