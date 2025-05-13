import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/customer/delete_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/presentation/registration/registration_event.dart';

import '../../core/di/setup.dart';
import '../../domain/use_case/customer/register_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';

class RegistrationViewModel with ChangeNotifier {
  void onEvent(RegistrationEvent event) {
    switch (event) {
      case RegisterCustomer():
        _onRegisterCustomer(
          customerMap: event.customerData,
          historyMap: event.historyData,
        );
      case UpdateCustomer():
        _onUpdateCustomer(customerMap: event.customerData);
      case DeleteCustomer():
        _deleteCustomer(customerKey: event.customerKey);
    }
  }

  void _onRegisterCustomer({
    required Map<String, dynamic> customerMap,
    required Map<String, dynamic> historyMap,
  }) {
    getIt<CustomerUseCase>().execute(
      usecase: RegisterCustomerUseCase(
        userKey: 'user1',
        customerData: customerMap,
        historyData: historyMap,
      ),
    );
  }

  void _onUpdateCustomer({required Map<String, dynamic> customerMap}) {
    getIt<CustomerUseCase>().execute(
      usecase: UpdateCustomerUseCase(
        userKey: 'user1',
        customerData: customerMap,
      ),
    );
  }

  Future _deleteCustomer({required String customerKey}) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: DeleteCustomerUseCase(customerKey: customerKey),
    );
  }
}
