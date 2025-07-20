import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../../../domain/model/policy_model.dart';
import '../../../presentation/customer/customer_view_model.dart';
import '../../domain/enum/policy_state.dart';
import '../core_presentation_import.dart';

Future<void> showEditPolicyDialog({
  required BuildContext context,
  required PolicyModel policy,
  required CustomerViewModel viewModel,
}) async {
  final TextEditingController premiumController = TextEditingController(
    text: policy.premium.toString(),
  );

  // 현재 상태 값을 enum으로 변환 (name -> enum)
  PolicyState? selectedState = PolicyState.values.firstWhere(
    (e) => e.name == policy.policyState,
    orElse: () => PolicyState.keep,
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('보험 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: premiumController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '보험료'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PolicyState>(
              value: selectedState,
              decoration: const InputDecoration(labelText: '보험 상태'),
              items:
                  PolicyState.values.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state.label), // ✅ 한글 라벨 표시
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) selectedState = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              // ✅ 콤마 제거 후 파싱
              final premiumText = premiumController.text.trim().replaceAll(
                ',',
                '',
              );
              final premium = int.tryParse(premiumText);
              if (premium == null) {
                showOverlaySnackBar(context, '올바른 보험료를 입력하세요');
                return;
              }

              final updatedPolicy = policy.copyWith(
                premium: premium.toString(),
                policyState: selectedState!.label, // ✅ 저장은 enum.name
              );

              await viewModel.updatePolicy(
                customerKey: policy.customerKey,
                policy: updatedPolicy,
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      );
    },
  );
}
