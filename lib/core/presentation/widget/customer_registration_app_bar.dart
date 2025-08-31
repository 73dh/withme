import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/insured_members_icon.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/core/presentation/widget/show_add_todo_dialog.dart';
import 'package:withme/core/utils/calculate_total_premium.dart';

import '../../../domain/domain_import.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';
import '../../../presentation/home/prospect_list/prospect_list_view_model.dart';
import '../../../presentation/registration/components/add_policy_button.dart';
import '../../../presentation/registration/components/edit_toggle_icon.dart';
import '../../../presentation/registration/registration_event.dart';
import '../../../presentation/registration/registration_view_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../domain/enum/policy_state.dart';
import '../../ui/const/app_bar_height.dart';
import '../../ui/core_ui_import.dart';
import '../components/blinking_calendar_icon.dart';
import '../core_presentation_import.dart';
import '../todo/manage_todo_list.dart';

class CustomerRegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final CustomerModel? customer;
  final TodoViewModel todoViewModel;
  final bool isReadOnly;
  final VoidCallback? onEditToggle;
  final VoidCallback? onHistoryTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel? registrationViewModel;
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
    this.registrationViewModel,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(customScreenAppbarHeight);

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
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InsuredMembersIcon(customer: customer!),
          width(10),

          /// 👉 총 계약 건수 & 총 보험료
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              height(5),
              // 계약 건수
              Text(
                '계약 ${customer!.policies.length}건 (정상 ${customer!.policies.where((p) => p.policyState == PolicyStatus.keep.label).length}건)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // 보험료
              Builder(
                builder: (_) {
                  final monthlyTotal = calculateTotalPremium(
                    customer!.policies
                        .where(
                          (p) =>
                              p.policyState == PolicyStatus.keep.label &&
                              p.paymentMethod == '월납',
                        )
                        .toList(),
                  );

                  final singleTotal = calculateTotalPremium(
                    customer!.policies
                        .where(
                          (p) =>
                              p.policyState == PolicyStatus.keep.label &&
                              p.paymentMethod == '일시납',
                        )
                        .toList(),
                  );

                  return Text(
                    '월납(납입중) $monthlyTotal원\n일시납 $singleTotal원',
                    style: theme.textTheme.bodySmall?.copyWith(color: fgColor),
                  );
                },
              ),
              height(5),
            ],
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ManageTodoList(
            viewModel: todoViewModel,
            customerSex: customer!.sex,
            textColor: fgColor,
            onAddPressed: () async {
              final newTodo = await showAddOrEditTodoDialog(context);
              if (newTodo != null) {
                await todoViewModel.addOrUpdateTodo(newTodo: newTodo);
              }
            },
          ),
        ),
        if (onHistoryTap != null) ...[
          width(8),
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
        ],
        if (onEditToggle != null) ...[
          width(10),
          EditToggleIcon(
            isReadOnly: isReadOnly,
            onPressed: onEditToggle!,
            color: fgColor,
          ),
        ],
        if (registrationViewModel != null) ...[
          width(5),
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
        ],
        width(10),
        AddPolicyButton(
          customerModel: customer!,
          onRegistered: (bool result) async {
            if (result) {
              await getIt<CustomerListViewModel>().refresh();
              await getIt<CustomerListViewModel>().fetchData();
            }
          },
          iconColor: fgColor,
        ),
        width(8),
      ],
    );
  }
}
