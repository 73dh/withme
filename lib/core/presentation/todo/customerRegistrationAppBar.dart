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
import 'common_todo_list.dart';

class CustomerRegistrationAppBar extends StatelessWidget   implements PreferredSizeWidget {
  final CustomerModel? customer;
  final TodoViewModel todoViewModel;

  // RegistrationAppBar 전용
  final bool isReadOnly;
  final VoidCallback? onEditToggle;
  final VoidCallback? onHistoryTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel? registrationViewModel;

  const CustomerRegistrationAppBar({
    super.key,
    required this.customer,
    required this.todoViewModel,
    this.isReadOnly = true,
    this.onEditToggle,
    this.onHistoryTap,
    this.isNeedNewHistory = false,
    this.registrationViewModel,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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

    return AnimatedBuilder(
      animation: todoViewModel,
      builder: (_, __) {
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: _buildTitle(),
          actions: _buildActions(context),
        );
      },
    );
  }

  Widget _buildTitle() {
    final iconPath = customer!.sex == '남'
        ? IconsPath.manIcon
        : IconsPath.womanIcon;
    return SexIconWithBirthday(
      birth: customer!.birth,
      sex: customer!.sex,
      backgroundImagePath: iconPath,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      CommonTodoList(customer: customer!, viewModel: todoViewModel),
      width(5),
      if (onHistoryTap != null) _buildHistoryButton(),
      if (onEditToggle != null) ...[
        width(10),
        EditToggleIcon(isReadOnly: isReadOnly, onPressed: onEditToggle!),
      ],
      width(5),
      if (registrationViewModel != null) _buildDeleteButton(context),
      width(10),
      _buildAddPolicyButton(),
      width(8),
    ];
  }

  Widget _buildHistoryButton() {
    return GestureDetector(
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
}