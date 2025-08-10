import '../../repository/todo_repository.dart';
import '../base/base_use_case.dart';

class DeleteTodoUseCase extends BaseUseCase<TodoRepository> {
  final String userKey;
  final String customerKey;
  final String todoId;

  DeleteTodoUseCase({
    required this.userKey,
    required this.customerKey,
    required this.todoId,
  });

  @override
  Future call(TodoRepository repository) async {
    return await repository.deleteTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoId: todoId,
    );
  }
}