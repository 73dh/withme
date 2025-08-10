import 'package:withme/domain/repository/todo_repository.dart';

import '../base/base_use_case.dart';

class UpdateTodoUseCase extends BaseUseCase<TodoRepository> {
  final String userKey;
  final String customerKey;
  final String todoId;
  final Map<String, dynamic> todoData;

  UpdateTodoUseCase({
    required this.userKey,
    required this.customerKey,
    required this.todoId,
    required this.todoData,
  });

  @override
  Future call(TodoRepository repository) async {
    return await repository.updateTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoId: todoId,
      todoData: todoData,
    );
  }
}