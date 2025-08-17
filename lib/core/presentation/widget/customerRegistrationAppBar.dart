import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';
import '../../../presentation/home/prospect_list/prospect_list_view_model.dart';
import '../../../presentation/registration/components/add_policy_button.dart';
import '../../../presentation/registration/components/edit_toggle_icon.dart';
import '../../../presentation/registration/registration_event.dart';
import '../../../presentation/registration/registration_view_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../components/blinking_calendar_icon.dart';
import '../core_presentation_import.dart';
import '../todo/common_todo_list.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/domain/domain_import.dart';
import '../todo/common_todo_list.dart';

class CustomerRegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final CustomerModel? customer;
  final TodoViewModel todoViewModel;
  final bool isReadOnly;
  final VoidCallback? onEditToggle;
  final VoidCallback? onHistoryTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel? registrationViewModel; // ← 추가
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomerRegistrationAppBar({
    super.key,
    required this.customer,
    required this.todoViewModel,
    this.isReadOnly = true,
    this.onEditToggle,
    this.onHistoryTap,
    this.isNeedNewHistory = false,
    this.registrationViewModel, // ← 추가
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = foregroundColor ?? colorScheme.onSurface;

    if (customer == null) {
      return AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        title: Text(
          'New',
          style: theme.textTheme.titleLarge?.copyWith(color: fgColor),
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      title: SexIconWithBirthday(
        birth: customer!.birth,
        sex: customer!.sex,
        backgroundImagePath:
            customer!.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon,
      ),
      actions: [
        StreamBuilder<List<TodoModel>>(
          stream: todoViewModel.todoStream,
          initialData: todoViewModel.todoList, // ✅ 초기값 제공
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final todos = snapshot.data ?? [];
            return CommonTodoList(
              customer: customer!,
              viewModel: todoViewModel,
              textColor: fgColor,
            );
          },
        ),
        const SizedBox(width: 8),
        if (onHistoryTap != null)
          GestureDetector(
            onTap: onHistoryTap,
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
                  Icon(Icons.menu, color: fgColor),
              ],
            ),
          ),
        if (onEditToggle != null) ...[
          const SizedBox(width: 10),
          EditToggleIcon(
            isReadOnly: isReadOnly,
            onPressed: onEditToggle!,
            color: fgColor,
          ),
        ],
        const SizedBox(width: 5),
        if (registrationViewModel != null)
          GestureDetector(
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                text: '가망고객을 삭제하시겠습니까?',
                onConfirm: () async {
                  await registrationViewModel?.onEvent(
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
            child: Image.asset(IconsPath.deleteIcon, width: 22, color: fgColor),
          ),
        const SizedBox(width: 10),
        AddPolicyButton(
          customerModel: customer!,
          onRegistered: (bool result) async {
            if (result) {
              await getIt<CustomerListViewModel>().refresh();
              await getIt<CustomerListViewModel>().fetchData();
            }
          },
          iconColor: fgColor, // AddPolicyButton 내부에서 theme 기반 색상
        ),
        width(8),
      ],
    );
  }
}
