import 'package:withme/core/presentation/todo/todo_action_mixin.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';

import '../../../domain/domain_import.dart';
import '../core_presentation_import.dart';

class CommonTodoList extends StatelessWidget with TodoActionMixin {
  final CustomerModel customer;
  final TodoViewModel viewModel;

  const CommonTodoList({
    super.key,
    required this.customer,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return BuildTodoList(
      viewModel: viewModel,
      customer: customer,
      onSelected: (_) => addOrUpdateTodo(context, customer),
      onPressed: () => addOrUpdateTodo(context, customer),
      onDeleteTodo: (todo) => deleteTodo(context, customer, todo),
      onUpdateTodo: (todo) => addOrUpdateTodo(context, customer, currentTodo: todo),
      onCompleteTodo: (todo) => completeTodo(context,customer, todo),
    );
  }
}
