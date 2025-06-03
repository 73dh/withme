import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/model/customer_model.dart';
import '../registration_event.dart';

class DeleteIcon extends StatelessWidget {
  final RegistrationViewModel viewModel;
  final CustomerModel customerModel;
  const DeleteIcon({super.key, required this.viewModel, required this.customerModel});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(IconsPath.deleteIcon, width: 25),
      onPressed: () async {
        final confirm = await showConfirmDialog(
          context,
          text: '가망고객을 삭제하시겠습니까?',
        );
        if (confirm == true && context.mounted) {
          viewModel.onEvent(
            RegistrationEvent.deleteCustomer(
              customerKey: customerModel.customerKey,
            ),
          );
          context.pop();
        }
      },
    );
  }
}
