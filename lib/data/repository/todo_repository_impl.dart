import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/repository/todo_repository.dart';

import '../../core/utils/transformers/transformers.dart';
import '../data_source/remote/fbase.dart';

class TodoRepositoryImpl with Transformers implements TodoRepository {
  final FBase fBase;

  TodoRepositoryImpl({required this.fBase});

  @override
  Stream<List<TodoModel>> getTodos({
    required String userKey,
    required String customerKey,
  }) {
    return fBase
        .getTodos(userKey: userKey, customerKey: customerKey)
        .transform(toTodos);
  }

  @override
  Future<void> addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  }) async {
    return await fBase.addTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoData: todoData,
    );
  }

  @override
  Future<void> deleteTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
  }) async {
    return await fBase.deleteTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoId: todoId,
    );
  }

  @override
  Future<void> updateTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
    required Map<String, dynamic> todoData,
  }) async {
    return await fBase.updateTodo(
      userKey: userKey,
      customerKey: customerKey,
      todoDocId: todoId,
      todoData: todoData,
    );
  }
}
