import 'package:withme/core/presentation/todo/todo_action_mixin.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';

import '../../../domain/domain_import.dart';
import '../core_presentation_import.dart';

// common_todo_list.dart
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/todo/todo_action_mixin.dart';
import 'package:withme/core/presentation/todo/build_todo_list.dart';
import '../../../domain/domain_import.dart';
import 'todo_view_model.dart';

class CommonTodoList extends StatelessWidget with TodoActionMixin {
  final CustomerModel customer;
  final TodoViewModel viewModel;
  final Color? textColor;

  const CommonTodoList({
    super.key,
    required this.customer,
    required this.viewModel,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return BuildTodoList(
      viewModel: viewModel,
      customer: customer,
      textColor: textColor,
      onSelected: (_) => addOrUpdateTodo(context, customer),
      onPressed: () => addOrUpdateTodo(context, customer),
      onDeleteTodo: (todo) => deleteTodo(context, customer, todo),
      onUpdateTodo: (todo) => addOrUpdateTodo(context, customer, currentTodo: todo),
      onCompleteTodo: (todo) => completeTodo(context, customer, todo),
    );
  }
}


