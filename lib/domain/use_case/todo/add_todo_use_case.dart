import 'package:withme/domain/repository/todo_repository.dart';

import '../base/base_use_case.dart';

class AddTodoUseCase extends BaseUseCase<TodoRepository> {
  final String userKey;
  final String customerKey;
  final Map<String, dynamic> todoData;

  AddTodoUseCase({
    required this.userKey,
    required this.customerKey,
    required this.todoData,
  });

  @override
  Future call(TodoRepository repository) async {
    return await repository.addTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoData: todoData,
    );
  }
}