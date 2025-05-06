import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../core/di/setup.dart';
import '../../data/data_source/remote/fbase.dart';
import '../model/customer_model.dart';

class GetPoolUseCase {
  Stream execute() {
    return getIt<CustomerRepository>().getPools();
  }
}
