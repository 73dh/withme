import 'package:go_router/go_router.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/use_case/todo/add_todo_use_case.dart';
import '../../../domain/use_case/todo/delete_todo_use_case.dart';
import '../../../domain/use_case/todo/update_todo_use_case.dart';
import '../../../domain/use_case/todo_use_case.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../core_presentation_import.dart';
import '../widget/show_add_todo_dialog.dart';

mixin TodoActionMixin {
  Future<void> addOrUpdateTodo(
      BuildContext context,
      CustomerModel customer,
      {TodoModel? currentTodo}
      ) async {
    final newTodo = await showAddOrEditTodoDialog(
      context,
      currentTodo: currentTodo,
    );
    if (newTodo == null) return;

    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    final useCase = currentTodo == null
        ? AddTodoUseCase(
      userKey: UserSession.userId,
      customerKey: customer.customerKey,
      todoData: todoData,
    )
        : UpdateTodoUseCase(
      userKey: UserSession.userId,
      customerKey: customer.customerKey,
      todoId: currentTodo.docId,
      todoData: todoData,
    );

    await getIt<TodoUseCase>().execute(usecase: useCase);
    if (context.mounted) context.pop();
  }

  Future<void> deleteTodo(
      BuildContext context,
      CustomerModel customer,
      TodoModel todo
      ) async {
    await getIt<TodoUseCase>().execute(
      usecase: DeleteTodoUseCase(
        userKey: UserSession.userId,
        customerKey: customer.customerKey,
        todoId: todo.docId,
      ),
    );
    if (context.mounted) context.pop();
  }

  Future<void> completeTodo(
      BuildContext context,
      TodoModel todo
      ) async {
    print('complete Todo: $todo');
    if (context.mounted) context.pop();
  }
}
