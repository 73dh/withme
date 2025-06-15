import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/customer/delete_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/presentation/registration/registration_event.dart';

import '../../core/di/setup.dart';
import '../../domain/use_case/customer/register_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';

class RegistrationViewModel with ChangeNotifier {
  Future<void> onEvent(RegistrationEvent event) async {
    switch (event) {
      case RegisterCustomer():
        _onRegisterCustomer(
          userKey: event.userKey,
          customerMap: event.customerData,
          historyMap: event.historyData,
        );
      case UpdateCustomer():
        await _onUpdateCustomer(customerMap: event.customerData);
      case DeleteCustomer():
        await _deleteCustomer(customerKey: event.customerKey);
    }
  }

  Future<void> _onRegisterCustomer({
    required String userKey,
    required Map<String, dynamic> customerMap,
    required Map<String, dynamic> historyMap,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: RegisterCustomerUseCase(
        userKey: userKey,
        customerData: customerMap,
        historyData: historyMap,
      ),
    );
  }

  Future<void> _onUpdateCustomer({
    required Map<String, dynamic> customerMap,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: UpdateCustomerUseCase(
        userKey: 'user1',
        customerData: customerMap,
      ),
    );
  }

  Future<void> _deleteCustomer({required String customerKey}) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: DeleteCustomerUseCase(customerKey: customerKey),
    );
  }
}
