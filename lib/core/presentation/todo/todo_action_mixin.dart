import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/domain/use_case/todo/complete_todo_use_case.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
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
      CustomerModel customer, {
        TodoModel? currentTodo,
      }) async {
    // 다크/라이트 테마 자동 적용은 showAddOrEditTodoDialog 내부에서 colorScheme 사용
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
await getIt<TodoViewModel>().initializeTodos(userKey: UserSession.userId, customerKey: customer.customerKey);
  }



  Future<void> deleteTodo(
      BuildContext context,
      CustomerModel customer,
      TodoModel todo,
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
    CustomerModel customer,
    TodoModel currentTodo,
  ) async {
    // Dialog 내부에서 theme/colorScheme 적용
    final editedTodo = await showAddOrEditTodoDialog(
      context,
      currentTodo: currentTodo,
      type: TodoDialogType.complete,
    );

    if (editedTodo == null) return;

    final newHistory = HistoryModel(
      contactDate: editedTodo.dueDate,
      content: editedTodo.content,
    );

    await getIt<TodoUseCase>().execute(
      usecase: CompleteTodoUseCase(
        userKey: customer.userKey,
        customerKey: customer.customerKey,
        todoId: currentTodo.docId,
        newHistory: newHistory,
      ),
    );

    if (context.mounted) {
      context.pop();
    }
  }
}
