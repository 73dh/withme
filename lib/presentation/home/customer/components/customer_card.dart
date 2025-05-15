import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/my_circular_indicator.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/policy_use_case.dart';
import 'package:withme/presentation/home/customer/customer_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/widget/circle_item.dart';
import '../../../../core/presentation/widget/sex_widget.dart';
import '../../../../core/presentation/widget/width_height.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../core/utils/calculate_age.dart';
import '../../../../core/utils/calculate_insurance_age.dart';
import '../../../../core/utils/days_until_insurance_age.dart';
import '../../../../core/utils/shortened_text.dart';
import '../../../../domain/model/customer_model.dart';
import '../../../../domain/model/policy_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerViewModel>();
    return StreamBuilder(
      stream: viewModel.getPolicies(customerKey: customer.customerKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(snapshot.error.toString());
        }
        if (snapshot.hasData) {
          List<PolicyModel> policies = snapshot.data;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // 그림자 색상
                  offset: const Offset(4, 4), // x, y 방향 으로 이동 (오른쪽 아래)
                  blurRadius: 6, // 흐림 정도
                  spreadRadius: 1, // 퍼짐 정도
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleItem(
                    number: policies.length,
                    color: Colors.redAccent.shade100,
                  ),
                  width(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_namePart(), _policyPart(policies)],
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _namePart() {
    int difference =
        getInsuranceAgeChangeDate(
          customer.birth!,
        ).difference(DateTime.now()).inDays;
    return Row(
      children: [
        Text(shortNameText(customer.name), style: TextStyles.bold14),
        width(5),
        sexIcon(customer.sex),
        width(5),
        Text(
          '${calculateAge(customer.birth!)}세/보험: ${calculateInsuranceAge(customer.birth!)}세',
        ),
        width(3),
        Text(
          '상령일: ${getInsuranceAgeChangeDate(customer.birth!).formattedDate}',
          style: TextStyle(
            color: difference <= 90 ? Colors.red : Colors.black87,
          ),
        ),
        Text(customer.recommended != '' ? customer.recommended : ''),
      ],
    );
  }

  _policyPart(List<PolicyModel> policies) {
    return Column(
      children: [
        ...policies.map((e) {
          return Row(
            children: [
              Text('${e.startDate?.formattedDate}'),
              Text('${e.productCategory}'),
              Text('${e.premium}'),
            ],
          );
        }),
      ],
    );
  }
}
