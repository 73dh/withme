import 'package:go_router/go_router.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';
// add_policy_button.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

// add_policy_button.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

class AddPolicyButton extends StatelessWidget {
  final CustomerModel customerModel;
  final Future<void> Function(bool result)? onRegistered;
  final Color? iconColor; // 추가

  const AddPolicyButton({
    super.key,
    required this.customerModel,
    this.onRegistered,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AddPolicyWidget(
      onTap: () async {
        context.pop();
        await context.push(RoutePath.policy, extra: customerModel);
      },
      iconColor: iconColor, // 전달
    );
  }
}
