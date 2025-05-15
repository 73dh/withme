import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/customer/get_customers_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';

class CustomerViewModel with ChangeNotifier{
  Stream getPolicies({required String customerKey}){
    return getIt<PolicyUseCase>().call(usecase: GetPoliciesUseCase(customerKey: customerKey));
  }
}