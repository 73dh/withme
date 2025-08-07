import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/data_chase_indicator.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/presentation/registration_sheet/part/build_todo_list.dart';

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
        AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) {
              return DataChaseIndicator();
            } else {
              return BuildTodoList(
                viewModel: viewModel,
                customer: customer,
                onSelected: (value) async {
                  await _onAddTodo(context);
                },
                onPressed: () async {
                  await _onAddTodo(context);
                },
              );
            }
          },
        ),
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

  Future<void> _onAddTodo(BuildContext context) async {
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
