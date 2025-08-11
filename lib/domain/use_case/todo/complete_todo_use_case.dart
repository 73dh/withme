import 'package:withme/domain/repository/todo_repository.dart';

import '../../model/history_model.dart';
import '../base/base_use_case.dart';

class CompleteTodoUseCase extends BaseUseCase<TodoRepository> {
  final String userKey;
  final String customerKey;
  final String todoId;
  final HistoryModel newHistory;

  CompleteTodoUseCase({
    required this.userKey,
    required this.customerKey,
    required this.todoId,
    required this.newHistory,
  });

  @override
  Future call(TodoRepository repository) async {
    return await repository.completeTodo(
      customerKey: customerKey,
      todoId: todoId,
      newHistory: newHistory,
    );
  }
}