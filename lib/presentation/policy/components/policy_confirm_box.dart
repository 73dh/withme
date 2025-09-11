import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';

import '../../../core/presentation/components/render_filled_button.dart';
import '../../../core/presentation/components/width_height.dart';
import '../../../core/presentation/widget/confirm_box_text.dart';

class PolicyConfirmBox extends StatelessWidget {
  final Map<String, dynamic> policyMap;
  final void Function() onChecked;
  final Color? backgroundColor;
  final Color? textColor;

  const PolicyConfirmBox({
    super.key,
    required this.policyMap,
    required this.onChecked,
    this.backgroundColor,
    this.textColor,
  });

  String _toDateFormatted(DateTime date) =>
      DateFormat('yyyy/MM/dd').format(date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerLowest;
    final fgColor = textColor ?? theme.colorScheme.onSurface;

    // 기본 정보
    final policyHolderName = policyMap[keyPolicyHolder] ?? '';
    final policyHolderSex = policyMap[keyPolicyHolderSex] ?? '';
    final policyHolderBirth =
        policyMap[keyPolicyHolderBirth] != null
            ? _toDateFormatted(policyMap[keyPolicyHolderBirth])
            : '';
    final insuredName = policyMap[keyInsured] ?? '';
    final insuredSex = policyMap[keyInsuredSex] ?? '';
    final insuredBirth =
        policyMap[keyInsuredBirth] != null
            ? _toDateFormatted(policyMap[keyInsuredBirth])
            : '';
    final productCategory = policyMap[keyProductCategory] ?? '';
    final insuranceCompany = policyMap[keyInsuranceCompany] ?? '';
    final productName = policyMap[keyProductName] ?? '';

    // 보험료
    final premium = policyMap[keyPremium]?.toString() ?? '';
    final paymentMethod = policyMap[keyPaymentMethod]?.toString() ?? '';
    final paymentPeriodRaw = policyMap[keyPaymentPeriod]?.toString() ?? '';

    // 납입기간 표시 처리 (월납: 숫자+년, 일시납: '일시납')
    String displayPaymentPeriod = '';
    if (paymentMethod == '월납') {
      displayPaymentPeriod =
          paymentPeriodRaw.isNotEmpty ? '$paymentPeriodRaw년' : '';
    } else if (paymentMethod == '일시납') {
      displayPaymentPeriod = '일시납';
    }

    // 계약일/만기일
    final startDate =
        policyMap[keyStartDate] != null
            ? _toDateFormatted(policyMap[keyStartDate])
            : '';
    final endDate =
        policyMap[keyEndDate] != null
            ? _toDateFormatted(policyMap[keyEndDate])
            : '';

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계약정보 확인',
            style: theme.textTheme.titleLarge?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          height(15),
          ConfirmBoxText(
            text: '계약자: ',
            text2: '$policyHolderName ($policyHolderSex) $policyHolderBirth',
            textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
          ),
          ConfirmBoxText(
            text: '피보험자: ',
            text2: '$insuredName ($insuredSex) $insuredBirth',
            textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
          ),
          ConfirmBoxText(
            text: '상품종류: ',
            text2: '$productCategory ($insuranceCompany)',
            textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
          ),
          ConfirmBoxText(
            text: '상품명: ',
            text2: productName,
            textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
          ),
          ConfirmBoxText(
            text: '보험료: ',
            text2:
                paymentMethod == '월납'
                    ? '$premium원 ($paymentMethod, $paymentPeriodRaw년)'
                    : '$premium원 ($paymentMethod)',
            textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
          ),
          Row(
            children: [
              ConfirmBoxText(
                text: '계약일: ',
                text2: startDate,
                textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
              ),
              width(10),
              ConfirmBoxText(
                text: '만기일: ',
                text2: endDate,
                textStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
              ),
            ],
          ),
          height(20),
          RenderFilledButton(
            onPressed: () {
              onChecked();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            text: '계약 저장',
            borderRadius: 10,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
