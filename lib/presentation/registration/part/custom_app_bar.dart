import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';
import '../components/edit_toggle_icon.dart';
import '../registration_event.dart';

class CustomAppBar extends StatelessWidget {
  final bool isReadOnly;
  final void Function() onPressed;
  final RegistrationViewModel viewModel;
  final CustomerModel? customerModel;

  const CustomAppBar({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    required this.viewModel,
    required this.customerModel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      actions: [
        EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
        if (isReadOnly)
          IconButton(
            icon: Image.asset(IconsPath.deleteIcon, width: 25),
            onPressed: () async {
              await showConfirmDialog(
                context,
                text: '가망고객을 삭제하시겠습니까?',
                onConfirm: () async {
                  // 삭제 처리
                  viewModel.onEvent(
                    RegistrationEvent.deleteCustomer(
                      customerKey: customerModel!.customerKey,
                    ),
                  );
                  // 캐시 초기화 및 재로드
                  final prospectViewModel = getIt<ProspectListViewModel>();
                  prospectViewModel.clearCache(); // 캐시 클리어
                  await prospectViewModel.fetchData(force: true); // 강제 새로고침
                },
              );
              if (context.mounted) {
                context.pop();
              }
            },
          ),
      ],
    );
  }
}
