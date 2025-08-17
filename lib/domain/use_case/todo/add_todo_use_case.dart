import 'package:withme/domain/repository/todo_repository.dart';

import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../model/todo_model.dart';
import '../base/base_use_case.dart';
import 'package:flutter/material.dart'; // 다이얼로그용

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
