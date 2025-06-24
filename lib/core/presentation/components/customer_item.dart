import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/policy_state.dart';
import 'package:withme/core/presentation/widget/item_container.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';

import '../../di/setup.dart';

import '../../ui/color/color_style.dart';
import '../core_presentation_import.dart';
import '../../ui/text_style/text_styles.dart';
import '../../utils/calculate_age.dart';
import '../../utils/calculate_insurance_age.dart';
import '../../utils/days_until_insurance_age.dart';
import '../../utils/shortened_text.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';

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
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        List<PolicyModel> policies = snapshot.data;
        return ItemContainer(child: Row(
          children: [
            CircleItem(number: policies.length, sex: customer.sex),
            width(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_namePart(), _policyPart(policies)],
            ),
          ],
        ));
      },
    );
  }

  Widget _namePart() {
    int difference =
        getInsuranceAgeChangeDate(
          customer.birth ?? DateTime.now(),
        ).difference(DateTime.now()).inDays;
    return Row(
      children: [
        Text(
          shortenedNameText(customer.name, length: 6),
          style: TextStyles.bold14,
        ),
        width(5),
        // sexIcon(customer.sex),
        // width(5),
        Text('${calculateAge(customer.birth ?? DateTime.now())}세'),
        width(3),
        Text(
          ' /상령일: ${getInsuranceAgeChangeDate(customer.birth ?? DateTime.now()).formattedDate}',
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
            final style =
                e.policyState == PolicyState.cancelled.label ||
                        e.policyState == PolicyState.lapsed.label
                    ? TextStyles.cancelStyle
                    : null;

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
