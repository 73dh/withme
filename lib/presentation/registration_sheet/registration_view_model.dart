import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/customer/delete_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/domain/use_case/todo/add_todo_use_case.dart';
import 'package:withme/domain/use_case/todo/get_todos_use_case.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';
import 'package:withme/presentation/registration_sheet/registration_event.dart';

import '../../core/data/fire_base/user_session.dart';
import '../../core/di/setup.dart';
import '../../domain/model/customer_model.dart';
import '../../domain/model/todo_model.dart';
import '../../domain/repository/customer_repository.dart';
import '../../domain/use_case/customer/get_edited_all_use_case.dart';
import '../../domain/use_case/customer/register_customer_use_case.dart';
import '../../domain/use_case/customer_use_case.dart';

class RegistrationViewModel with ChangeNotifier {
  Stream<List<TodoModel>>? _todoStream;

  Stream<List<TodoModel>>? get todoStream => _todoStream;

  List<TodoModel> _todoList = [];

  List<TodoModel> get todoList => _todoList;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  late final TodoUseCase _todoUseCase = getIt<TodoUseCase>();
  StreamSubscription<List<TodoModel>>? _subscription;

  Future<void> initializeTodos(String userKey, String customerKey) async {
    _todoStream = _todoUseCase.call(
      usecase: GetTodosUseCase(userKey: userKey, customerKey: customerKey),
    );

    _subscription?.cancel();
    _subscription = _todoStream!.listen((todos) {
      _todoList = todos;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 필요 시 onEvent에서도 initializeTodos 호출
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
      case DeleteTodo():
        _onDeleteTodo(
          userKey: event.userKey,
          customerKey: event.customerKey,
          todoId: event.todoId,
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

  Future<void> _addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _todoUseCase.execute(
      usecase: AddTodoUseCase(
        userKey: userKey,
        customerKey: customerKey,
        todoData: todoData,
      ),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _onDeleteTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
  }) async {
    print('$customerKey $todoId');
  }
}
