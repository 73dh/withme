import 'dart:async';

import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/customer/delete_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/presentation/registration_sheet/registration_event.dart';

import '../../core/data/fire_base/user_session.dart';
import '../../core/di/setup.dart';
import '../../domain/use_case/customer/register_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';

class RegistrationViewModel with ChangeNotifier {
  Future<void> onEvent(RegistrationEvent event) async {
    switch (event) {
      case RegisterCustomer():
        await _onRegisterCustomer(
          userKey: UserSession.userId,
          customerMap: event.customerData,
          historyMap: event.historyData,
          // todoMap: event.todoData
        );
      case UpdateCustomer():
        await _onUpdateCustomer(
          userKey: UserSession.userId,
          customerMap: event.customerData,
        );
      case DeleteCustomer():
        await _deleteCustomer(
          userKey: UserSession.userId,
          customerKey: event.customerKey,
        );
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
    required String userKey,
    required Map<String, dynamic> customerMap,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: UpdateCustomerUseCase(
        userKey: userKey,
        customerData: customerMap,
      ),
    );
  }

  Future<void> _deleteCustomer({
    required String userKey,
    required String customerKey,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: DeleteCustomerUseCase(
        userKey: userKey,
        customerKey: customerKey,
      ),
    );
  }

  // Future<void> _addTodo({
  //   required String userKey,
  //   required String customerKey,
  //   required Map<String, dynamic> todoData,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   await _todoUseCase.execute(
  //     usecase: AddTodoUseCase(
  //       userKey: userKey,
  //       customerKey: customerKey,
  //       todoData: todoData,
  //     ),
  //   );
  //   _isLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<void> _onDeleteTodo({
  //   required String userKey,
  //   required String customerKey,
  //   required String todoId,
  // }) async {
  //   await _todoUseCase.execute(
  //     usecase: DeleteTodoUseCase(
  //       userKey: userKey,
  //       customerKey: customerKey,
  //       todoId: todoId,
  //     ),
  //   );
  //   notifyListeners();
  // }
}
