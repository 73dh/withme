import 'package:go_router/go_router.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';

class AddPolicyButton extends StatelessWidget {
  final CustomerModel customerModel;
  final Future<void> Function(bool result)? onRegistered;

  // final VoidCallback? onFailed; // 👈 실패 시 호출 콜백 추가

  const AddPolicyButton({
    super.key,
    required this.customerModel,
    this.onRegistered,
    // this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    return AddPolicyWidget(
      onTap: () async {
        context.pop();
        await context.push(RoutePath.policy, extra: customerModel);
      },
    );
  }
}
