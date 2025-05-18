import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';

import '../../../../core/di/setup.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../core/utils/calculate_age.dart';
import '../../../../core/utils/calculate_insurance_age.dart';
import '../../../../core/utils/days_until_insurance_age.dart';
import '../../../../core/utils/shortened_text.dart';
import '../../../../domain/model/customer_model.dart';
import '../../../../domain/model/policy_model.dart';
import '../customer_list_view_model.dart';

class CustomerItem extends StatelessWidget {
  final CustomerModel customer;

  const CustomerItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerListViewModel>();
    return StreamBuilder(
      stream: viewModel.getPolicies(customerKey: customer.customerKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(snapshot.error.toString());
        }
        if (snapshot.hasData) {
          List<PolicyModel> policies = snapshot.data;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
            ),
          );
        } else {
          return const SizedBox.shrink();
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
        Text(shortenedNameText(customer.name), style: TextStyles.bold14),
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

  Widget _policyPart(List<PolicyModel> policies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          policies.map((e) {
            final style = e.policyState == '해지' ? TextStyles.cancelStyle : null;

            return Row(
              children: [
                Text(e.startDate?.formattedDate ?? '', style: style),
                width(5),
                Text(e.productCategory, style: style),
                width(5),
                Text(
                  '${numFormatter.format(int.tryParse(e.premium) ?? 0)} (${e.paymentMethod})',
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }).toList(),
    );
  }
}
