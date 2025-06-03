import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

class AddPolicyButton extends StatelessWidget {
  final CustomerModel customerModel;
  const AddPolicyButton({super.key, required this.customerModel});

  @override
  Widget build(BuildContext context) {
    return  AddPolicyWidget(
      onTap: () => context.push(RoutePath.policy, extra: customerModel),
    );
  }
}
