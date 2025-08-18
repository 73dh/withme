import 'dart:async';

import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';

import '../../../domain/model/history_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/complete_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo/update_todo_use_case.dart';

class TodoViewModel with ChangeNotifier {
  final String userKey;
  final String customerKey;
  final _todoUseCase = getIt<TodoUseCase>();

  TodoViewModel({required this.userKey, required this.customerKey});

  final List<TodoModel> _todoList = [];

  List<TodoModel> get todoList => List.unmodifiable(_todoList);

  /// Firestore 초기 로드
  void loadTodos(List<TodoModel> todos) {
    _todoList
      ..clear()
      ..addAll(todos);
    notifyListeners();
  }

  /// 추가 또는 수정
  Future<void> addOrUpdateTodo({
    TodoModel? currentTodo,
    required TodoModel newTodo,
  }) async {
    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    final useCase =
        currentTodo == null
            ? AddTodoUseCase(
              userKey: userKey,
              customerKey: customerKey,
              todoData: todoData,
            )
            : UpdateTodoUseCase(
              userKey: userKey,
              customerKey: customerKey,
              todoId: currentTodo.docId,
              todoData: todoData,
            );

    await _todoUseCase.execute(usecase: useCase);
    // 로컬 리스트 반영
    if (currentTodo == null) {
      _todoList.add(newTodo);
    } else {
      final index = _todoList.indexWhere((t) => t.docId == currentTodo.docId);
      if (index != -1) _todoList[index] = newTodo;
    }

    notifyListeners();
  }

  /// 삭제
  Future<void> deleteTodo(TodoModel todo) async {
    await _todoUseCase.execute(
      usecase: DeleteTodoUseCase(
        userKey: userKey,
        customerKey: customerKey,
        todoId: todo.docId,
      ),
    );
    _todoList.removeWhere((t) => t.docId == todo.docId);
    notifyListeners();
  }

  /// 완료 처리 + History 등록
  Future<void> completeTodo(TodoModel currentTodo, TodoModel editedTodo) async {
    final newHistory = HistoryModel(
      contactDate: editedTodo.dueDate,
      content: editedTodo.content,
    );

    await _todoUseCase.execute(
      usecase: CompleteTodoUseCase(
        userKey: userKey,
        customerKey: customerKey,
        todoId: currentTodo.docId,
        newHistory: newHistory,
      ),
    );
    // 완료된 Todo 삭제
    _todoList.removeWhere((t) => t.docId == currentTodo.docId);

    notifyListeners();
  }
}

//
// class TodoViewModel with ChangeNotifier {
//   final _fbase = FBase();
//
//   Stream<List<TodoModel>>? _todoStream;
//
//   Stream<List<TodoModel>>? get todoStream => _todoStream;
//
//   final List<TodoModel> _todoList = [];
//
//   List<TodoModel> get todoList => _todoList;
//
//   final bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   StreamSubscription<List<TodoModel>>? _subscription;
//
//   /// 초기화 및 실시간 데이터 수신 시작
//   Future<void> initializeTodos({
//     required String userKey,
//     required String customerKey,
//   }) async {
//     _todoStream = _fbase
//         .getTodos(userKey: userKey, customerKey: customerKey)
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => TodoModel.fromSnapshot(doc))
//               .toList();
//         });
//
//     _subscription?.cancel();
//
//     _subscription = _todoStream!.listen((todos) {
//       _todoList
//         ..clear()
//         ..addAll(todos);
//       notifyListeners();
//     });
//   }
// }
