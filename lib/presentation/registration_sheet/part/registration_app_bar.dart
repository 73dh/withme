import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/components/orbiting_dots.dart';
import '../../../core/presentation/core_presentation_import.dart';
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
  final void Function() onPressed;
  final void Function() onTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel viewModel;
  final CustomerModel? customerModel;
  // final void Function(bool result)? isSuccess;

  const RegistrationAppBar({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    required this.onTap,
    required this.isNeedNewHistory,
    required this.viewModel,
    required this.customerModel,
    // required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Image.asset(
        customerModel?.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon,
        fit: BoxFit.cover,
        color: getSexIconColor(customerModel?.sex).withOpacity(0.6),
      ),

      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isNeedNewHistory)
                    BlinkingCursorIcon(
                      key: ValueKey(isNeedNewHistory), // 상태가 바뀌면 강제로 새로 빌드됨
                      sex: customerModel?.sex ?? '',
                      size: 30,
                    ),
                  if (!isNeedNewHistory) const Icon(Icons.menu),
                ],
              ),
            ),

            width(10),
            EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
            width(5),
            GestureDetector(
              onTap: () async {
                if (customerModel == null) {
                  debugPrint('CustomerModel is null, cannot delete.');
                  return;
                }

                final confirmed = await showConfirmDialog(
                  context,
                  text: '가망고객을 삭제하시겠습니까?',
                  onConfirm: () async {
                    await viewModel.onEvent(
                      RegistrationEvent.deleteCustomer(
                        userKey: UserSession.userId,
                        customerKey: customerModel!.customerKey,
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
            ),
            width(10),
            if (customerModel != null)
              AddPolicyButton(
                customerModel: customerModel!,
                onRegistered: (bool result) async {
                  if (result) {
                    await getIt<CustomerListViewModel>().refresh();
                  } else {
                    debugPrint('등록 취소 또는 실패');
                    // isSuccess?.call(result);
                  }
                },

              ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
