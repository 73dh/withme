import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/policy_state.dart';
import 'package:withme/core/presentation/components/item_icon.dart';
import 'package:withme/core/presentation/components/orbiting_dots.dart';
import 'package:withme/core/presentation/widget/item_container.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';

import '../../../domain/model/history_model.dart';
import '../../data/fire_base/user_session.dart';
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
import '../widget/history_part_widget.dart';
import '../widget/insurance_age_widget.dart';

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
          return const SizedBox.shrink();
        }

        List<PolicyModel> policies = snapshot.data;
        return ItemContainer(
          child: Stack(
            children: [
              Row(
                children: [
                  ItemIcon(
                    number: policies.length,
                    sex: customer.sex,
                    backgroundImagePath: 'assets/icons/folder.png',
                  ),
                  width(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_namePart(), _policyPart(policies)],
                  ),
                  const Spacer(),
                ],
              ),
              if (_isInactive(customer.histories))
                Positioned(
                  top: 0,
                  right: 0,
                  child: BlinkingCursorIcon(sex: customer.sex, size: 20),
                ),
            ],
          ),
        );

      },
    );
  }
  bool _isInactive(List<HistoryModel> histories) {
    if (histories.isEmpty) return true;

    final recent = histories
        .map((h) => h.contactDate) // History의 date 필드를 기준으로
        .whereType<DateTime>() // null 방지
        .fold<DateTime?>(null, (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev);

    if (recent == null) return true;

    final managePeriod = getIt<UserSession>().managePeriodDays;
    final now = DateTime.now();
    return now.difference(recent).inDays >= managePeriod;
  }


  Widget _namePart() {
    return Row(
      children: [
        Text(
          shortenedNameText(customer.name, length: 6),
          style: TextStyles.bold14,
        ),
        width(5),
        Text('${calculateAge(customer.birth ?? DateTime.now())}세/'),
        width(3),
        InsuranceAgeWidget(birthDate: customer.birth ?? DateTime.now()),
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
                Text(e.startDate?.formattedDate ?? ''),
                width(5),
                Text(e.productCategory),
                width(5),

                Text(
                  numFormatter.format(
                    int.tryParse(e.premium.replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0,
                  ),
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
                width(5),
                Text(' (${e.paymentMethod})', overflow: TextOverflow.ellipsis),
              ],
            );
          }).toList(),
    );
  }
}
