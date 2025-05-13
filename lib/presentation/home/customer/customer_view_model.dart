import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/customer/get_customers_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';

class CustomerViewModel with ChangeNotifier{
  Stream getCustomers(){
    return getIt<CustomerUseCase>().call(usecase: GetCustomersUseCase());
  }
}