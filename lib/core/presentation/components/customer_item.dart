import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/policy_state.dart';
import 'package:withme/core/presentation/components/prospect_item_icon.dart';
import 'package:withme/core/presentation/components/orbiting_dots.dart';
import 'package:withme/core/presentation/widget/item_container.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';
import 'package:withme/core/utils/is_need_new_history.dart';

import '../../../domain/model/history_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';

import '../../ui/color/color_style.dart';
import '../../utils/show_history_util.dart';
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
import 'customer_item_icon.dart';

class CustomerItem extends StatelessWidget {
  final CustomerModel customer;

  const CustomerItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerListViewModel>();
    final birthDate = customer.birth;

    final info = customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return StreamBuilder(
      stream: viewModel.getPolicies(customerKey: customer.customerKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        List<PolicyModel> policies = snapshot.data!;
        final showReminder = showHistoryUtil(customer.histories).showReminder;
        return ItemContainer(
          // height: 99,
          backgroundColor: isUrgent ? ColorStyles.isUrgentColor : null,
          child: Stack(
            children: [
              Row(
                children: [
                  CustomerItemIcon(
                    customer: customer,
                  ),
                  width(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _namePart(
                        birthDate,
                        difference,
                        isUrgent,
                        insuranceChangeDate,
                      ),
                      _policyPart(policies),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              if (showReminder)
                Positioned(
                  top: 0,
                  right: 0,
                  child: BlinkingCursorIcon(sex: customer.sex, size: 25),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _namePart(
    DateTime? birthDate,
    int? difference,
    bool isUrgent,
    DateTime? insuranceChangeDate,
  ) {
    if (birthDate == null) {
      return Row(
        children: [
          Text(
            shortenedNameText(customer.name, length: 6),
            style: TextStyles.bold14,
          ),
          width(5),
          const Text('정보 없음'),
          width(3),
          Text(customer.recommended.isNotEmpty ? customer.recommended : ''),
        ],
      );
    }

    return Row(
      children: [
        Text(
          shortenedNameText(customer.name, length: 6),
          style: TextStyles.bold14,
        ),
        width(5),
        Text('${calculateAge(birthDate)}세/'),
        width(3),
        if (difference != null &&
            difference >= 0 &&
            insuranceChangeDate != null)
          InsuranceAgeWidget(
            difference: difference,
            isUrgent: isUrgent,
            insuranceChangeDate: insuranceChangeDate,
          ),
        if (difference == null || difference < 0) const SizedBox.shrink(),
        Text(customer.recommended.isNotEmpty ? customer.recommended : ''),
      ],
    );
  }

  Widget _policyPart(List<PolicyModel> policies) {
    final bool showPrev = policies.length > 1;

    // 가장 최근 1개
    final List<PolicyModel> recentPolicies =
    showPrev ? policies.reversed.take(1).toList().reversed.toList() : policies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPrev)
          const Text(
            '...prev',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ...recentPolicies.map((e) {
          final isCancelled = e.policyState == PolicyState.cancelled.label ||
              e.policyState == PolicyState.lapsed.label;

          final premiumText = numFormatter.format(
            int.tryParse(e.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.startDate?.formattedDate ?? ''),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  e.productCategory,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              width(5),
              Text(
                premiumText,
                style: TextStyle(
                  color: isCancelled ? Colors.red : null,
                  fontWeight: isCancelled ? FontWeight.bold : null,
                  decoration:
                  isCancelled ? TextDecoration.lineThrough : null,
                  decorationColor: isCancelled ? Colors.red : null,
                  decorationThickness: isCancelled ? 2 : null,
                ),
              ),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  ' (${e.paymentMethod})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
