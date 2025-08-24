import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/birthday_badge.dart';
import 'package:withme/core/presentation/components/customer_item_icon.dart';
import 'package:withme/core/presentation/components/prospect_item_icon.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/core/presentation/widget/show_add_todo_dialog.dart';

import '../../../domain/domain_import.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';
import '../../../presentation/home/prospect_list/prospect_list_view_model.dart';
import '../../../presentation/registration/components/add_policy_button.dart';
import '../../../presentation/registration/components/edit_toggle_icon.dart';
import '../../../presentation/registration/registration_event.dart';
import '../../../presentation/registration/registration_view_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/is_birthday_within_7days.dart';
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme=theme.textTheme;

    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = foregroundColor ?? colorScheme.onSurface;


    final bool hasUpcomingBirthday =
        customer?.birth != null && isBirthdayWithin7Days(customer!.birth!);

    final int countdown =
    customer?.birth != null ? getBirthdayCountdown(customer!.birth!) : -1;

    final Color cakeColor = Colors.redAccent;

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
      title:
          registrationViewModel != null
              ? Row(
                children: [
                  ProspectItemIcon(customer: customer!),
                  BirthdayBadge(birth: customer!.birth!,textSize: 24,),
                  // if (hasUpcomingBirthday)
                  //   Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(
                  //         Icons.cake_rounded,
                  //         color: cakeColor,
                  //         size: 35 *0.8,
                  //       ),
                  //       Text(
                  //         countdown != 0 ? '-$countdown' : '오늘',
                  //         style: textTheme.titleLarge?.copyWith(
                  //           color: cakeColor,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              )
              : Column(
                children: [CustomerItemIcon(customer: customer!), height(15)],
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
        width(8),
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
          width(10),
          EditToggleIcon(
            isReadOnly: isReadOnly,
            onPressed: onEditToggle!,
            color: fgColor,
          ),
        ],
        width(5),
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
