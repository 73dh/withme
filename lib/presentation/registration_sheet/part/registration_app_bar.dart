import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/components/orbiting_dots.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/show_history_util.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
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
    print('customer: $customer');
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: _buildTitle(),
      actions: [_buildActions(context)],
    );
  }

  Widget _buildTitle() {
    if (customer == null) return const Text('New');
    final iconPath =
        customer?.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon;
    final color = getSexIconColor(customer?.sex).withOpacity(0.6);
    return Image.asset(iconPath, fit: BoxFit.cover, color: color);
  }

  Widget _buildActions(BuildContext context) {
    if (customer == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTodoList(context),
        _buildHistoryButton(),
        width(10),
        EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
        width(5),
        _buildDeleteButton(context),
        width(10),
        _buildAddPolicyButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTodoList(BuildContext context) {
    final List<TodoModel> todoList = customer?.todos ?? [];
    todoList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final TodoModel? nearestTodo = todoList.isNotEmpty ? todoList.first : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nearestTodo != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  nearestTodo.content,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '할 일 목록',
                icon: const Icon(Icons.expand_more),
                onSelected: (value) async {
                  if (value == 'add') {
                    final newTodo = await showAddTodoDialog(context);
                    if (newTodo != null) {
                      final todoData = TodoModel.toMapForCreateTodo(
                        content: newTodo.content,
                        dueDate: newTodo.dueDate,
                      );

                      await viewModel.onEvent(
                        RegistrationEvent.addTodo(
                          userKey: UserSession.userId,
                          customerKey: customer?.customerKey ?? '',
                          todoData: todoData,
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (context) {
                  final List<PopupMenuEntry<String>> items = [];

                  for (int i = 0; i < todoList.length; i++) {
                    final todo = todoList[i];
                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${todo.dueDate.formattedDate} ${todo.content}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      // await viewModel.onEvent(
                                      //   RegistrationEvent.addTodo(
                                      //     userKey: UserSession.userId,
                                      //     customerKey: customerModel!.customerKey,
                                      //     todoData:
                                      //   ),
                                      // );
                                      // await viewModel.fetchCustomer(); // 갱신
                                      // Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text('완료, 관리이력 추가'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () async {
                                    // await viewModel.onEvent(
                                    //   RegistrationEvent.deleteTodo(
                                    //     userKey: UserSession.userId,
                                    //     customerKey: customerModel!.customerKey,
                                    //     todoKey: todo.todoKey!,
                                    //   ),
                                    // );
                                    // await viewModel.fetchCustomer(); // 갱신
                                    // Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '할 일 삭제',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i != todoList.length - 1)
                              const PopupMenuDivider(),
                          ],
                        ),
                      ),
                    );
                  }

                  items.add(
                    PopupMenuItem<String>(
                      value: 'add',
                      child: Row(
                        children: const [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 6),
                          Text('할 일 추가'),
                        ],
                      ),
                    ),
                  );

                  return items;
                },
              ),
            ],
          ),
        if (todoList.isEmpty)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '할 일 추가',
            onPressed: () async {
              final newTodo = await showAddTodoDialog(context);
              if (newTodo != null) {
                final todoData = TodoModel.toMapForCreateTodo(
                  content: newTodo.content,
                  dueDate: newTodo.dueDate,
                );

                await viewModel.onEvent(
                  RegistrationEvent.addTodo(
                    userKey: UserSession.userId,
                    customerKey: customer?.customerKey ?? '',
                    todoData: todoData,
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isNeedNewHistory)
            BlinkingCursorIcon(
              key: ValueKey(isNeedNewHistory),
              sex: customer?.sex ?? '',
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

        if (context.mounted && confirmed == true) {
          context.pop();
        }
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
          await getIt<CustomerListViewModel>().fetchData(); // 정책 등록 후 갱신
        } else {
          debugPrint('등록 취소 또는 실패');
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
