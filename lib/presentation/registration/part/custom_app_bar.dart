import 'package:flutter/material.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../domain/domain_import.dart';
import '../components/delete_icon.dart';
import '../components/edit_toggle_icon.dart';

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
          DeleteIcon(viewModel: viewModel, customerModel: customerModel!),
      ],
    );
  }
}
