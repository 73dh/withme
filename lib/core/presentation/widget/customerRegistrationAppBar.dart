import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';

import '../../../domain/domain_import.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';
import '../../../presentation/home/prospect_list/prospect_list_view_model.dart';
import '../../../presentation/registration_sheet/components/add_policy_button.dart';
import '../../../presentation/registration_sheet/components/edit_toggle_icon.dart';
import '../../../presentation/registration_sheet/registration_event.dart';
import '../../../presentation/registration_sheet/registration_view_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../components/blinking_calendar_icon.dart';
import '../core_presentation_import.dart';
import '../todo/common_todo_list.dart';
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
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    // customer가 null일 때 단순 New AppBar
    if (customer == null) {
      return AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottomOpacity: 0,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        title: const Text('New'),
      );
    }

    // customer가 있을 때
    return AnimatedBuilder(
      animation: todoViewModel,
      builder: (_, __) {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          bottomOpacity: 0,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          title: SexIconWithBirthday(
            birth: customer!.birth,
            sex: customer!.sex,
            backgroundImagePath:
            customer!.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon,
          ),
          actions: [
            CommonTodoList(customer: customer!, viewModel: todoViewModel),
            width(5),
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
              EditToggleIcon(isReadOnly: isReadOnly, onPressed: onEditToggle!),
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
                child: Image.asset(IconsPath.deleteIcon, width: 22),
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
            ),
            width(8),
          ],
        );
      },
    );
  }
}

//
// class CustomerRegistrationAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final CustomerModel? customer;
//   final TodoViewModel todoViewModel;
//
//   // RegistrationAppBar 전용
//   final bool isReadOnly;
//   final VoidCallback? onEditToggle;
//   final VoidCallback? onHistoryTap;
//   final bool isNeedNewHistory;
//   final RegistrationViewModel? registrationViewModel;
//
//   // 추가: 테마 색상 전달
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//
//   const CustomerRegistrationAppBar({
//     super.key,
//     required this.customer,
//     required this.todoViewModel,
//     this.isReadOnly = true,
//     this.onEditToggle,
//     this.onHistoryTap,
//     this.isNeedNewHistory = false,
//     this.registrationViewModel,
//     this.backgroundColor,
//     this.foregroundColor,
//   });
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
//     final fgColor = foregroundColor ?? Theme.of(context).colorScheme.onSurface;
//
//     if (customer == null) {
//       return AppBar(
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         shadowColor: Colors.transparent,       // 그림자 제거
//         surfaceTintColor: Colors.transparent,  // M3 테마 경계 제거
//         bottomOpacity: 0, // 👈 추가
//         backgroundColor: bgColor,
//         foregroundColor: fgColor,
//         title: const Text('New'),
//       );
//     }
//
//     return AnimatedBuilder(
//       animation: todoViewModel,
//       builder: (_, __) {
//         return AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           shadowColor: Colors.transparent,       // 그림자 제거
//           surfaceTintColor: Colors.transparent,  // M3 테마 경계 제거
//           backgroundColor: bgColor,
//           foregroundColor: fgColor,
//           title: _buildTitle(),
//           actions: _buildActions(context, fgColor),
//         );
//       },
//     );
//   }
//
//   Widget _buildTitle() {
//     final iconPath =
//         customer!.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon;
//     return SexIconWithBirthday(
//       birth: customer!.birth,
//       sex: customer!.sex,
//       backgroundImagePath: iconPath,
//     );
//   }
//
//   List<Widget> _buildActions(BuildContext context, Color iconColor) {
//     return [
//       CommonTodoList(customer: customer!, viewModel: todoViewModel),
//       width(5),
//       if (onHistoryTap != null) _buildHistoryButton(iconColor),
//       if (onEditToggle != null) ...[
//         width(10),
//         EditToggleIcon(isReadOnly: isReadOnly, onPressed: onEditToggle!),
//       ],
//       width(5),
//       if (registrationViewModel != null) _buildDeleteButton(context),
//       width(10),
//       _buildAddPolicyButton(),
//       width(8),
//     ];
//   }
//
//   Widget _buildHistoryButton(Color iconColor) {
//     return GestureDetector(
//       onTap: onHistoryTap,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (isNeedNewHistory)
//             BlinkingCalendarIcon(
//               key: ValueKey(isNeedNewHistory),
//               sex: customer!.sex,
//               size: 30,
//             )
//           else
//             Icon(Icons.menu, color: iconColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeleteButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         final confirmed = await showConfirmDialog(
//           context,
//           text: '가망고객을 삭제하시겠습니까?',
//           onConfirm: () async {
//             await registrationViewModel?.onEvent(
//               RegistrationEvent.deleteCustomer(
//                 userKey: UserSession.userId,
//                 customerKey: customer!.customerKey,
//               ),
//             );
//             final prospectViewModel = getIt<ProspectListViewModel>();
//             prospectViewModel.clearCache();
//             await prospectViewModel.fetchData(force: true);
//           },
//         );
//         if (context.mounted && confirmed == true) context.pop();
//       },
//       child: Image.asset(IconsPath.deleteIcon, width: 22),
//     );
//   }
//
//   Widget _buildAddPolicyButton() {
//     return AddPolicyButton(
//       customerModel: customer!,
//       onRegistered: (bool result) async {
//         if (result) {
//           await getIt<CustomerListViewModel>().refresh();
//           await getIt<CustomerListViewModel>().fetchData();
//         }
//       },
//     );
//   }
// }
