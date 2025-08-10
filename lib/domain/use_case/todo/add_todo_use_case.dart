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

//
// class AddTodoUseCase extends BaseUseCase<TodoRepository> {
//   final String userKey;
//   final String customerKey;
//   final BuildContext context;  // context 추가
//
//   AddTodoUseCase({
//     required this.userKey,
//     required this.customerKey,
//     required this.context,
//   });
//
// //   @override
// //   Future call(TodoRepository repository) async {
// //     // 다이얼로그 띄워서 todo 입력 받기
// //     final newTodo = await showAddTodoDialog(context);
// //
// //     if (newTodo == null) return null;
// //
// //     final todoData = TodoModel.toMapForCreateTodo(
// //       content: newTodo.content,
// //       dueDate: newTodo.dueDate,
// //     );
// //
// //     // 저장 호출
// //     return await repository.addTodo(
// //       userKey: userKey,
// //       customerKey: customerKey,
// //       todoData: todoData,
// //     );
// //   }
// // }
//
// // class AddTodoUseCase extends BaseUseCase<TodoRepository> {
// //   final String userKey;
// //   final String customerKey;
// //   final Map<String, dynamic> todoData;
// //
// //   AddTodoUseCase({
// //     required this.userKey,
// //     required this.customerKey,
// //     required this.todoData,
// //   });
// //
//   @override
//   Future call(TodoRepository repository) async {
//     return await repository.addTodo(
//       userKey: userKey,
//       customerKey: customerKey,
//       todoData: todoData,
//     );
//
//
//   }
// // }