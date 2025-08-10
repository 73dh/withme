import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/todo/add_todo_use_case.dart';
import 'package:withme/domain/use_case/todo/delete_todo_use_case.dart';
import 'package:withme/domain/use_case/todo/update_todo_use_case.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/components/blinking_calendar_icon.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';
import '../components/add_policy_button.dart';
import '../components/edit_toggle_icon.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isReadOnly;
  final VoidCallback onPressed;
  final VoidCallback onTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel viewModel;
  final CustomerModel? customer;

  const RegistrationAppBar({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    required this.onTap,
    required this.isNeedNewHistory,
    required this.viewModel,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    if (customer == null) {
      return AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('New'),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: _buildTitle(),
      actions: [_buildActions(context)],
    );
  }

  Widget _buildTitle() {
    final iconPath = customer!.sex == '남' ? IconsPath.manIcon : IconsPath
        .womanIcon;
    return SexIconWithBirthday(
      birth: customer!.birth,
      sex: customer!.sex,
      backgroundImagePath: iconPath,
    );
  }

  Widget _buildActions(BuildContext context) {
    final todoViewModel = getIt<TodoViewModel>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BuildTodoList(
          viewModel: todoViewModel,
          customer: customer,
          onSelected: (_) => _addOrUpdateTodo(context),
          onPressed: () => _addOrUpdateTodo(context),
          onDeleteTodo: (todo) => _deleteTodo(context, todo),
          onUpdateTodo: (todo) => _addOrUpdateTodo(context, currentTodo: todo),
          onCompleteTodo: (todo) => _completeTodo(context, todo),
        ),
        width(5),
        _buildHistoryButton(),
        width(10),
        EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
        width(5),
        _buildDeleteButton(context),
        width(10),
        _buildAddPolicyButton(),
        width(8),
      ],
    );
  }

  Future<void> _addOrUpdateTodo(BuildContext context,
      {TodoModel? currentTodo}) async {
    final newTodo = await showAddOrEditTodoDialog(
        context, currentTodo: currentTodo);
    if (newTodo == null) return;

    final todoData = TodoModel.toMapForCreateTodo(
      content: newTodo.content,
      dueDate: newTodo.dueDate,
    );

    final useCase = currentTodo == null
        ? AddTodoUseCase(
      userKey: UserSession.userId,
      customerKey: customer!.customerKey,
      todoData: todoData,
    )
        : UpdateTodoUseCase(
      userKey: UserSession.userId,
      customerKey: customer!.customerKey,
      todoId: currentTodo.docId,
      todoData: todoData,
    );

    await getIt<TodoUseCase>().execute(usecase: useCase);
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

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isNeedNewHistory)
            BlinkingCalendarIcon(
              key: ValueKey(isNeedNewHistory),
              sex: customer!.sex,
              size: 30,
            )
          else
            const Icon(Icons.menu),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showConfirmDialog(
          context,
          text: '가망고객을 삭제하시겠습니까?',
          onConfirm: () async {
            await viewModel.onEvent(
              RegistrationEvent.deleteCustomer(
                userKey: UserSession.userId,
                customerKey: customer!.customerKey,
              ),
            );
            final prospectViewModel = getIt<ProspectListViewModel>();
            prospectViewModel.clearCache();
            await prospectViewModel.fetchData(force: true);
          },
        );
        if (context.mounted && confirmed == true) context.pop();
      },
      child: Image.asset(IconsPath.deleteIcon, width: 22),
    );
  }

  Widget _buildAddPolicyButton() {
    return AddPolicyButton(
      customerModel: customer!,
      onRegistered: (bool result) async {
        if (result) {
          await getIt<CustomerListViewModel>().refresh();
          await getIt<CustomerListViewModel>().fetchData();
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

