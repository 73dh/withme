import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';

import '../../../core/presentation/widget/confirm_box_text.dart';
import '../../../core/presentation/widget/render_filled_button.dart';
import '../../../core/presentation/widget/width_height.dart';
import '../../../core/ui/color/color_style.dart';
import '../../../core/ui/text_style/text_styles.dart';

class PolicyConfirmBox extends StatelessWidget {
  final Map<String, dynamic> policyMap;
  final void Function(bool) onChecked;

  const PolicyConfirmBox({super.key, required this.policyMap, required this.onChecked});

  _toDateFormatted(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final _policyHolderName = policyMap[keyPolicyHolder];
    final _policyHolderSex = policyMap[keyPolicyHolderSex];
    final _policyHolderBirth = _toDateFormatted(
      policyMap[keyPolicyHolderBirth],
    );
    final _insuredName = policyMap[keyInsured];
    final _insuredSex = policyMap[keyInsuredSex];
    final _insuredBirth = _toDateFormatted(policyMap[keyInsuredBirth]);
    final _productCategory = policyMap[keyProductCategory];
    final _insuranceCompany = policyMap[keyInsuranceCompany];
    final _productName = policyMap[keyProductName];
    final _premiumController = policyMap[keyPremium];
    final _paymentMethod = policyMap[keyPaymentMethod];
    final _startDate = _toDateFormatted(policyMap[keyStartDate]);
    final _endDate = _toDateFormatted(policyMap[keyEndDate]);

    return Column(
      children: [
        height(20),
        Text('계약정보 확인', style: TextStyles.bold20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(10),
              ConfirmBoxText(
                text: '계약자: ',
                text2:
                    '${_policyHolderName} (${_policyHolderSex}) ${_policyHolderBirth}',
              ),

              ConfirmBoxText(
                text: '피보험자: ',
                text2: '${_insuredName} (${_insuredSex}) ${_insuredBirth}',
              ),
              ConfirmBoxText(
                text: '상품종류: ',
                text2: '${_productCategory} (${_insuranceCompany})',
              ),
              ConfirmBoxText(text: '상품명: ', text2: '${_productName}'),
              ConfirmBoxText(
                text: '보험료: ',
                text2: '${_premiumController}원 (${_paymentMethod})',
              ),
              Row(
                children: [
                  ConfirmBoxText(text: '계약일: ', text2: '${_startDate}'),
                  width(10),
                  ConfirmBoxText(text: '만기일: ', text2: '${_endDate}'),
                ],
              ),
              height(20),
              RenderFilledButton(
                onPressed:() {
onChecked(true);
context.pop();
                },
                text: '계약 저장',
                borderRadius: 10,
                backgroundColor: ColorStyles.activeButtonColor,
                foregroundColor: Colors.black87,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
