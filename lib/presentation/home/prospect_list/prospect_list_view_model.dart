import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/domain/use_case/history_use_case.dart';

import '../../../core/di/setup.dart';
import '../../../domain/use_case/customer/get_prospect_use_case.dart';
import '../../../domain/use_case/history/get_histories_use_case.dart';

class ProspectListViewModel with ChangeNotifier {
  Stream getProspects() {
    return getIt<CustomerUseCase>().call(usecase: GetProspectUseCase());
  }
}
