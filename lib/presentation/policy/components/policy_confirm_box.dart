import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';

import '../../../core/presentation/components/render_filled_button.dart';
import '../../../core/presentation/components/width_height.dart';
import '../../../core/presentation/widget/confirm_box_text.dart';

class PolicyConfirmBox extends StatelessWidget {
  final Map<String, dynamic> policyMap;
  final void Function() onChecked;

  const PolicyConfirmBox({
    super.key,
    required this.policyMap,
    required this.onChecked,
  });

  String _toDateFormatted(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final policyHolderName = policyMap[keyPolicyHolder];
    final policyHolderSex = policyMap[keyPolicyHolderSex];
    final policyHolderBirth = _toDateFormatted(policyMap[keyPolicyHolderBirth]);
    final String insuredName = policyMap[keyInsured];
    final String insuredSex = policyMap[keyInsuredSex];
    final String insuredBirth = _toDateFormatted(policyMap[keyInsuredBirth]);
    final String productCategory = policyMap[keyProductCategory];
    final String insuranceCompany = policyMap[keyInsuranceCompany];
    final String productName = policyMap[keyProductName];
    final String premiumController = policyMap[keyPremium];
    final String paymentMethod = policyMap[keyPaymentMethod];
    final String startDate = _toDateFormatted(policyMap[keyStartDate]);
    final String endDate = _toDateFormatted(policyMap[keyEndDate]);

    return Column(
      children: [
        height(25),
        Text(
          '계약정보 확인',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(15),
              ConfirmBoxText(
                text: '계약자: ',
                text2:
                    '$policyHolderName ($policyHolderSex) $policyHolderBirth',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              ConfirmBoxText(
                text: '피보험자: ',
                text2: '$insuredName ($insuredSex) $insuredBirth',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              ConfirmBoxText(
                text: '상품종류: ',
                text2: '$productCategory ($insuranceCompany)',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              ConfirmBoxText(
                text: '상품명: ',
                text2: productName,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              ConfirmBoxText(
                text: '보험료: ',
                text2: '$premiumController원 ($paymentMethod)',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  ConfirmBoxText(
                    text: '계약일: ',
                    text2: startDate,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  width(10),
                  ConfirmBoxText(
                    text: '만기일: ',
                    text2: endDate,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              height(20),
              RenderFilledButton(
                onPressed: () {
                  onChecked();

                  if (!context.mounted) return; // 이미 dispose 된 경우 실행 안 함
                  Navigator.of(context, rootNavigator: true).pop();
                },
                text: '계약 저장',
                borderRadius: 10,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
