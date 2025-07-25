import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

class AddPolicyButton extends StatelessWidget {
  final CustomerModel customerModel;
  final Future<void> Function(bool result)? onRegistered;
  final VoidCallback? onFailed;  // 👈 실패 시 호출 콜백 추가

  const AddPolicyButton({
    super.key,
    required this.customerModel,
    this.onRegistered, this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    return AddPolicyWidget(
      onTap: () async {
        final result = await context.push(
          RoutePath.policy,
          extra: customerModel,
        );
        final bool isSuccess=result==true;
        await onRegistered?.call(isSuccess);
        // if (result == true) {
        //   onRegistered?.call(result);
        // }
        if (!isSuccess) {
          onFailed?.call();  // 👈 실패 시 FAB 숨김용 콜백 호출
        }
      },
    );
  }
}
