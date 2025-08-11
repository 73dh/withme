import 'package:go_router/go_router.dart';
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
    final newTodo = await showAddOrEditTodoDialog(
      context,
      currentTodo: currentTodo,
    );
    if (newTodo == null) return;

    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    final useCase =
        currentTodo == null
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
    // 1. 팝업에서 현재 todo 내용과 날짜 보여주고, 필요시 수정
    final editedTodo = await showAddOrEditTodoDialog(
      context,
      currentTodo: currentTodo,
      type: TodoDialogType.complete,
    );

    // 2. 사용자가 취소 버튼을 눌렀다면 종료
    if (editedTodo == null) return;
    // 3. Usecase 실행
    final newHistory = HistoryModel(
      contactDate: editedTodo.dueDate,
      content: editedTodo.content,
    );
    await getIt<TodoUseCase>().execute(
      usecase: CompleteTodoUseCase(
        userKey: customer.userKey,
        customerKey: customer.customerKey,
        todoId: currentTodo.docId,
        newHistory: newHistory, // 수정된 내용 전달
      ),
    );

    // 4. 팝업 닫기
    if (context.mounted) {
      context.pop();
    }
  }
}
