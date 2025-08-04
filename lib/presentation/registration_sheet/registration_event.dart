import '../../domain/model/todo_model.dart';

sealed class RegistrationEvent {
  factory RegistrationEvent.registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
    required Map<String, dynamic> todoData,
  }) = RegisterCustomer;

  factory RegistrationEvent.updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) = UpdateCustomer;

  factory RegistrationEvent.deleteCustomer({
    required String userKey,
    required String customerKey,
  }) = DeleteCustomer;

  factory RegistrationEvent.addTodo({
    required String userKey,
    required String customerKey,
    required Map<String,dynamic> todoData,
  }) = AddTodo;
}

class RegisterCustomer implements RegistrationEvent {
  final String userKey;
  final Map<String, dynamic> customerData;
  final Map<String, dynamic> historyData;
  final Map<String, dynamic> todoData;

  RegisterCustomer({
    required this.userKey,
    required this.customerData,
    required this.historyData,
    required this.todoData,
  });
}

class UpdateCustomer implements RegistrationEvent {
  final String userKey;
  final Map<String, dynamic> customerData;

  UpdateCustomer({required this.userKey, required this.customerData});
}

class DeleteCustomer implements RegistrationEvent {
  final String userKey;
  final String customerKey;

  DeleteCustomer({required this.userKey, required this.customerKey});
}

class AddTodo implements RegistrationEvent {
  final String userKey;
  final String customerKey;
  final Map<String, dynamic> todoData;

  AddTodo({
    required this.userKey,
    required this.customerKey,
    required this.todoData,
  });
}
