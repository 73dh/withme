import 'package:go_router/go_router.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/use_case/todo/update_todo_use_case.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/router/router_path.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo_use_case.dart';
import '../../../core/presentation/todo/todo_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/use_case/todo/update_todo_use_case.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/router/router_path.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo_use_case.dart';
import '../../../core/presentation/todo/todo_view_model.dart';

class CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomerModel customer;
  final TodoViewModel todoViewModel;

  const CustomerAppBar({
    super.key,
    required this.customer,
    required this.todoViewModel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _addTodo(BuildContext context) async {
    final newTodo = await showAddOrEditTodoDialog(context);
    if (newTodo == null) return;

    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    await getIt<TodoUseCase>().execute(
      usecase: AddTodoUseCase(
        userKey: UserSession.userId,
        customerKey: customer.customerKey ?? '',
        todoData: todoData,
      ),
    );
  }

  Future<void> _updateTodo(BuildContext context, TodoModel todo) async {
    final newTodo = await showAddOrEditTodoDialog(context, currentTodo: todo);
    if (newTodo == null) return;

    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    await getIt<TodoUseCase>().execute(
      usecase: UpdateTodoUseCase(
        userKey: UserSession.userId,
        customerKey: customer.customerKey ?? '',
        todoId: todo.docId,
        todoData: todoData,
      ),
    );

    if (context.mounted) context.pop();
  }

  Future<void> _deleteTodo(BuildContext context, TodoModel todo) async {
    await getIt<TodoUseCase>().execute(usecase: DeleteTodoUseCase(
        userKey: UserSession.userId,
        customerKey: customer!.customerKey,
        todoId: todo.docId));
    if (context.mounted) context.pop();
  }

  Future<void> _completeTodo(BuildContext context, TodoModel todo) async {
    print('complete Todo: $todo');
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: todoViewModel,
      builder: (context, _) {
        return AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${customer.registeredDate.formattedBirth})',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            BuildTodoList(
              viewModel: todoViewModel,
              customer: customer,
              onSelected: (value) async => await _addTodo(context),
              onPressed: () async => await _addTodo(context),
              onDeleteTodo: (todo) async => await _deleteTodo(context, todo),
              onUpdateTodo: (todo) async => await _updateTodo(context, todo),
              onCompleteTodo: (todo) async=>await _completeTodo(context,todo),
            ),
            width(25),
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: AddPolicyWidget(
                size: 40,
                onTap: () async {
                  final updated = await context.push<bool>(
                    RoutePath.policy,
                    extra: customer,
                  );
                  if (updated == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
