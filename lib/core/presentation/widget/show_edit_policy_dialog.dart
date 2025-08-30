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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final holderController = TextEditingController(text: policy.policyHolder);
  final premiumController = TextEditingController(text: policy.premium);

  DateTime? holderBirth = policy.policyHolderBirth;
  final holderBirthController = TextEditingController(
    text:
        holderBirth != null
            ? '${holderBirth.year}-${holderBirth.month.toString().padLeft(2, '0')}-${holderBirth.day.toString().padLeft(2, '0')}'
            : '',
  );

  PolicyStatus selectedState = PolicyStatus.values.firstWhere(
    (e) => e.name == policy.policyState,
    orElse: () => PolicyStatus.keep,
  );

  const List<String> sexes = ['남', '여'];
  String? holderSex = policy.policyHolderSex;

  InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
  );

  await showDialog(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder:
              (context, setState) => Dialog(
                backgroundColor: Colors.transparent,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '계약 정보 변경',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        height(16),

                        // 계약자 이름
                        TextFormField(
                          controller: holderController,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          decoration: inputDecoration('계약자 이름'),
                        ),
                        height(16),

                        // 계약자 성별
                        DropdownButtonFormField<String>(
                          value: holderSex,
                          decoration: inputDecoration('계약자 성별'),
                          items:
                              sexes
                                  .map(
                                    (sex) => DropdownMenuItem(
                                      value: sex,
                                      child: Text(
                                        sex,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => holderSex = value);
                            }
                          },
                        ),
                        height(16),

                        // 계약자 생년월일
                        TextFormField(
                          readOnly: true,
                          controller: holderBirthController,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: holderBirth ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                holderBirth = picked;
                                holderBirthController.text =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          decoration: inputDecoration('생년월일').copyWith(
                            hintText: '생년월일 선택',
                            suffixIcon: const Icon(
                              Icons.cake_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                        height(16),

                        // 보험료
                        TextFormField(
                          controller: premiumController,
                          keyboardType: TextInputType.number,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          decoration: inputDecoration('보험료'),
                        ),
                        height(16),

                        // 보험 상태
                        DropdownButtonFormField<PolicyStatus>(
                          value: selectedState,
                          decoration: inputDecoration('보험 상태'),
                          items:
                              PolicyStatus.values
                                  .map(
                                    (state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(
                                        state.label,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedState = value);
                            }
                          },
                        ),
                        height(24),

                        // 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                foregroundColor: colorScheme.onSurface,
                                minimumSize: const Size(80, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('취소'),
                            ),
                            width(10),
                            FilledButton(
                              onPressed: () async {
                                final holderName = holderController.text.trim();
                                final premiumText = premiumController.text
                                    .trim()
                                    .replaceAll(',', '');
                                final premium = int.tryParse(premiumText);

                                if (holderName.isEmpty) {
                                  return showOverlaySnackBar(
                                    context,
                                    '계약자 이름을 입력하세요',
                                  );
                                }
                                if (holderSex == null) {
                                  return showOverlaySnackBar(
                                    context,
                                    '계약자 성별을 선택하세요',
                                  );
                                }
                                if (holderBirth == null) {
                                  return showOverlaySnackBar(
                                    context,
                                    '계약자 생년월일을 선택하세요',
                                  );
                                }
                                if (premium == null || premium < 0) {
                                  return showOverlaySnackBar(
                                    context,
                                    '올바른 보험료를 입력하세요',
                                  );
                                }

                                if (selectedState == PolicyStatus.fired) {
                                  await viewModel.deletePolicy(
                                    customerKey: policy.customerKey,
                                    policyKey: policy.policyKey,
                                  );
                                } else {
                                  final updatedPolicy = policy.copyWith(
                                    policyHolder: holderName,
                                    policyHolderSex: holderSex,
                                    policyHolderBirth: holderBirth,
                                    premium: premium.toString(),
                                    policyState: selectedState.label,
                                  );

                                  await viewModel.updatePolicy(
                                    customerKey: policy.customerKey,
                                    policy: updatedPolicy,
                                  );
                                }

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                minimumSize: const Size(80, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('저장'),
                            ),
                          ],
                        ),
                        height(10),
                      ],
                    ),
                  ),
                ),
              ),
        ),
  );
}
