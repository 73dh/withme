import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/prospect_item_icon.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/color/color_style.dart';
import '../../ui/text_style/text_styles.dart';
import '../../utils/calculate_age.dart';
import '../../utils/days_until_insurance_age.dart';
import '../../utils/shortened_text.dart';
import '../core_presentation_import.dart';
import '../widget/history_part_widget.dart';
import '../widget/insurance_age_widget.dart';
import '../widget/item_container.dart';

class SearchCustomerItem extends StatelessWidget {
  final String userKey;
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const SearchCustomerItem({
    super.key,
    required this.userKey,
    required this.customer,
    required this.onTap,
  });

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

        List<PolicyModel> policies = snapshot.data??[];
        return  ItemContainer(height: null,



          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProspectItemIcon(
                  number: policies.length,
                  sex: customer.sex,
                  backgroundImagePath: 'assets/icons/folder.png',
                ),
                width(20),
                Expanded( // ✅ Row 안에서 넘치는 부분을 감싸 제한함
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_namePart(), _policyPart(policies)],
                        ),
                      ),
                      width(10),
                      Flexible(
                        flex: 1,
                        child: StreamBuilder(
                          stream: getIt<HistoryUseCase>().call(
                            usecase: GetHistoriesUseCase(
                              userKey: userKey,
                              customerKey: customer.customerKey,
                            ),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const MyCircularIndicator();
                            }

                            List<HistoryModel> histories = snapshot.data!;
                            return HistoryPartWidget(
                              histories: histories,
                              onTap: (histories) => onTap(histories),sex: customer.sex,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        );
      },
    );
  }

  Widget _namePart() {
    final birthDate = customer.birth;
    if (birthDate == null) return const SizedBox.shrink();

    final insuranceChangeDate = getInsuranceAgeChangeDate(birthDate);
    final int difference = insuranceChangeDate.difference(DateTime.now()).inDays;

    // 지난 상령일은 표시하지 않음
    if (difference < 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(shortenedNameText(customer.name), style: TextStyles.bold14),
              width(5),
              Text(
                '${birthDate.formattedBirth} (${calculateAge(birthDate)}세)',
                style: TextStyles.normal12,
              ),
            ],
          ),
          if (customer.recommended.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('소개자: ${customer.recommended}', style: TextStyles.normal12),
            ),
        ],
      );
    }

    final isUrgent = difference <= getIt<UserSession>().urgentThresholdDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(shortenedNameText(customer.name), style: TextStyles.bold14),
            width(5),
            Text(
              '${birthDate.formattedBirth} (${calculateAge(birthDate)}세)',
              style: TextStyles.normal12,
            ),
          ],
        ),

        // ✅ 상령일 위젯 (미래 상령일만 표시)
        InsuranceAgeWidget(
          difference: difference,
          isUrgent: isUrgent,
          insuranceChangeDate: insuranceChangeDate,
        ),

        if (customer.recommended.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('소개자: ${customer.recommended}', style: TextStyles.normal12),
          ),
      ],
    );
  }


  // Widget _namePart() {
  //   int difference =
  //       getInsuranceAgeChangeDate(
  //         customer.birth ?? DateTime.now(),
  //       ).difference(DateTime.now()).inDays;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(shortenedNameText(customer.name), style: TextStyles.bold14),
  //           width(5),
  //           // sexIcon(customer.sex),
  //           // width(5),
  //           Text(
  //             '${customer.birth?.formattedBirth} (${calculateAge(customer.birth ?? DateTime.now())}세)',
  //           ),
  //           width(3),
  //         ],
  //       ),
  //       InsuranceAgeWidget(birthDate: customer.birth ?? DateTime.now()),
  //
  //       if (customer.recommended != '') Text(customer.recommended),
  //     ],
  //   );
  // }

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
                Text(e.productCategory, style: style,
                  overflow: TextOverflow.ellipsis,),
                width(5),

              ],
            );
          }).toList(),
    );
  }
}
