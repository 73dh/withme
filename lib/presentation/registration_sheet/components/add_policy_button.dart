import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

class AddPolicyButton extends StatelessWidget {
  final CustomerModel customerModel;
  final VoidCallback? onRegistered;

  const AddPolicyButton({
    super.key,
    required this.customerModel,
    this.onRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return AddPolicyWidget(
      onTap: () async {
        final result = await context.push(
          RoutePath.policy,
          extra: customerModel,
        );
        if (result == true) {
          onRegistered?.call();
        }
      },
    );
  }
}
