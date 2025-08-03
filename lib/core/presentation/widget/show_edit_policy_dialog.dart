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

  PolicyState? selectedState = PolicyState.values.firstWhere(
        (e) => e.name == policy.policyState,
    orElse: () => PolicyState.keep,
  );

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade500, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '보험료 & 계약상태 변경',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: premiumController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '보험료',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PolicyState>(
                    value: selectedState,
                    decoration: const InputDecoration(
                      labelText: '보험 상태',
                      border: OutlineInputBorder(),
                    ),
                    items: PolicyState.values.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(state.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedState = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // 취소
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(80, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () async {
                          final premiumText = premiumController.text.trim().replaceAll(',', '');
                          final premium = int.tryParse(premiumText);

                          if (premium == null || premium < 0) {
                            showOverlaySnackBar(context, '올바른 보험료를 입력하세요');
                            return;
                          }

                          if (selectedState == PolicyState.fired) {
                            await viewModel.deletePolicy(
                              customerKey: policy.customerKey,
                              policyKey: policy.policyKey,
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            return;
                          }

                          final updatedPolicy = policy.copyWith(
                            premium: premium.toString(),
                            policyState: selectedState!.label,
                          );

                          await viewModel.updatePolicy(
                            customerKey: policy.customerKey,
                            policy: updatedPolicy,
                          );

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(80, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

//
// Future<void> showEditPolicyDialog({
//   required BuildContext context,
//   required PolicyModel policy,
//   required CustomerViewModel viewModel,
// }) async {
//   final TextEditingController premiumController = TextEditingController(
//     text: policy.premium.toString(),
//   );
//
//   PolicyState? selectedState = PolicyState.values.firstWhere(
//         (e) => e.name == policy.policyState,
//     orElse: () => PolicyState.keep,
//   );
//
//   await showDialog(
//     context: context,
//     builder: (dialogContext) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border.all(color: Colors.grey.shade500, width: 1.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     '보험료 & 계약상태 변경',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   height(16),
//                   TextFormField(
//                     controller: premiumController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: '보험료',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   height(16),
//                   DropdownButtonFormField<PolicyState>(
//                     value: selectedState,
//                     decoration: const InputDecoration(
//                       labelText: '보험 상태',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: PolicyState.values.map((state) {
//                       return DropdownMenuItem(
//                         value: state,
//                         child: Text(state.label),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       if (value != null) selectedState = value;
//                     },
//                   ),
//                   height(24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       FilledButton(
//                         onPressed: () {
//                           Navigator.of(dialogContext).pop(); // 취소
//                         },
//                         style: FilledButton.styleFrom(
//                           backgroundColor: Colors.grey,
//                           minimumSize: const Size(80, 40),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text('취소'),
//                       ),
//                       height(10),
//                       FilledButton(
//                         onPressed: () async {
//                           final premiumText = premiumController.text.trim().replaceAll(',', '');
//                           final premium = int.tryParse(premiumText);
//                           if (premium == null) {
//                             showOverlaySnackBar(context, '올바른 보험료를 입력하세요');
//                             return;
//                           }
//
//                           // fired 선택 시 삭제
//                           if (selectedState == PolicyState.fired) {
//                             await viewModel.deletePolicy(
//                               customerKey: policy.customerKey,
//                               policyKey: policy.policyKey,
//                             );
//                             if (context.mounted) {
//                               Navigator.pop(context);
//                             }
//                             return;
//                           }
//
//                           // 일반 수정 처리
//                           final updatedPolicy = policy.copyWith(
//                             premium: premium.toString(),
//                             policyState: selectedState!.label,
//                           );
//
//                           await viewModel.updatePolicy(
//                             customerKey: policy.customerKey,
//                             policy: updatedPolicy,
//                           );
//
//                           if (context.mounted) {
//                             Navigator.pop(context);
//                           }
//                         },
//                         style: FilledButton.styleFrom(
//                           minimumSize: const Size(80, 40),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text('저장'),
//                       ),
//                     ],
//                   ),
//                   height(10),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
//
