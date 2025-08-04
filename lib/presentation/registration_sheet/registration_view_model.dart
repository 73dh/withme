import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/customer/delete_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/domain/use_case/todo/add_todo_use_case.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';
import 'package:withme/presentation/registration_sheet/registration_event.dart';

import '../../core/data/fire_base/user_session.dart';
import '../../core/di/setup.dart';
import '../../domain/model/customer_model.dart';
import '../../domain/repository/customer_repository.dart';
import '../../domain/use_case/customer/get_edited_all_use_case.dart';
import '../../domain/use_case/customer/register_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';

class RegistrationViewModel with ChangeNotifier {

  CustomerModel? customer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final CustomerUseCase _customerUseCase = getIt<CustomerUseCase>();

  Future<void> fetchCustomer(String userKey, String customerKey) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _customerUseCase.execute(
        usecase: GetEditedAllUseCase(userKey: userKey),
      );
      customer = result;
    } catch (e) {
      // TODO: 에러 처리
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  }) async {
    await _customerUseCase.execute(
      usecase: AddTodoUseCase(userKey: userKey, customerKey: customerKey, todoData: todoData),
    );
    await fetchCustomer(userKey, customerKey); // 상태 갱신
  }

  // Future<void> completeTodo({
  //   required String userKey,
  //   required String customerKey,
  //   required String todoKey,
  // }) async {
  //   await _customerUseCase.execute(
  //     usecase: CompleteTodoUseCase(userKey: userKey, customerKey: customerKey, todoKey: todoKey),
  //   );
  //   await fetchCustomer(userKey, customerKey);
  // }
  //
  // Future<void> deleteTodo({
  //   required String userKey,
  //   required String customerKey,
  //   required String todoKey,
  // }) async {
  //   await _customerUseCase.execute(
  //     usecase: DeleteTodoUseCase(userKey: userKey, customerKey: customerKey, todoKey: todoKey),
  //   );
  //   await fetchCustomer(userKey, customerKey);
  // }

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
      case AddTodo():
        await _addTodo(
          userKey: event.userKey,
          customerKey: event.customerKey,
          todoData: event.todoData,
        );
    }
  }

  Future<void> _onRegisterCustomer({
    required String userKey,
    required Map<String, dynamic> customerMap,
    required Map<String, dynamic> historyMap,
    // required Map<String,dynamic>todoMap,
  }) async {
    return await getIt<CustomerUseCase>().execute(
      usecase: RegisterCustomerUseCase(
        userKey: userKey,
        customerData: customerMap,
        historyData: historyMap,
        // todoData: todoMap,
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

  Future<void> _addTodo({
    required String userKey,
    required String customerKey,
    required Map<String,dynamic> todoData,
  }) async {
    return await getIt<TodoUseCase>().execute(
      usecase: AddTodoUseCase(
        userKey: userKey,
        customerKey: customerKey,
        todoData: todoData,
      ),
    );
  }
}
