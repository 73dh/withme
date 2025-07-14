import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';
import '../components/add_policy_button.dart';
import '../components/edit_toggle_icon.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isReadOnly;
  final void Function() onPressed;
  final RegistrationViewModel viewModel;
  final CustomerModel? customerModel;

  const RegistrationAppBar({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    required this.viewModel,
    required this.customerModel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        '가망고객정보',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black, // 필요시 ColorStyles.textColor 등 사용
        ),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(onTap: (){
              
            }, child: Icon(Icons.directions_run)),
            EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
            width(5),
            GestureDetector(
              onTap: () async {
                if (customerModel == null) {
                  debugPrint('CustomerModel is null, cannot delete.');
                  return;
                }

                final bool? confirmed = await showConfirmDialog(
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
                onRegistered: () async {
                  await getIt<CustomerListViewModel>().refresh();
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

