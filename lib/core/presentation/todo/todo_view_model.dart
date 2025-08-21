import 'dart:async';

import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';

import '../../../domain/model/history_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/complete_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo/update_todo_use_case.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/model/history_model.dart';
import 'package:withme/core/di/setup.dart';
import '../../../domain/use_case/todo_use_case.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/update_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo/complete_todo_use_case.dart';

import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/update_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo/complete_todo_use_case.dart';

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

    if (currentTodo == null) {
      _todoList.add(newTodo);
    } else {
      final index = _todoList.indexWhere((t) => t.docId == currentTodo.docId);
      if (index != -1) _todoList[index] = newTodo;
    }

    notifyListeners();
  }

  /// 삭제 (Firestore + 로컬)
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
    // 1) 수정된 내용으로 History 생성
    final newHistory = HistoryModel(
      contactDate: editedTodo.dueDate,
      content: editedTodo.content,
    );

    // 2) Firestore 처리 (완료 = History 추가 + Todo 삭제)
    await _todoUseCase.execute(
      usecase: CompleteTodoUseCase(
        userKey: userKey,
        customerKey: customerKey,
        todoId: currentTodo.docId,
        newHistory: newHistory,
      ),
    );

    // 3) 로컬 리스트에서 제거
    await deleteTodo(currentTodo); // ✅ deleteTodo 호출로 일관성 유지
  }
}
