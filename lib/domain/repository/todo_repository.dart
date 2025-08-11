import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/repository/repository.dart';

import '../model/history_model.dart';

abstract interface class TodoRepository implements Repository {
  Stream<List<TodoModel>> getTodos({
    required String userKey,
    required String customerKey,
  });

  Future<void> addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  });

  Future<void> updateTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
    required Map<String, dynamic> todoData,
  });

  Future<void> deleteTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
  });

  Future<void> completeTodo({

    required String customerKey,
    required String todoId,
    required HistoryModel newHistory,
  });
}
