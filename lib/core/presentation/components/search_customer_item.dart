import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../di/setup.dart';
import '../../ui/text_style/text_styles.dart';
import '../../utils/calculate_age.dart';
import '../../utils/days_until_insurance_age.dart';
import '../../utils/shortened_text.dart';
import '../core_presentation_import.dart';
import '../widget/history_part_widget.dart';

class SearchCustomerItem extends StatelessWidget {
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const SearchCustomerItem({
    super.key,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleItem(
                    number: policies.length,
                    color: Colors.redAccent.shade100,
                  ),
                  width(20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_namePart(), _policyPart(policies)],
                  ),
                  Expanded(
                    // fit: FlexFit.loose,
                    child: StreamBuilder(
                      stream: getIt<HistoryUseCase>().call(
                        usecase: GetHistoriesUseCase(
                          customerKey: customer.customerKey,
                        ),
                      ),
                      //     .fetchHistories(
                      //   customer.customerKey,
                      // ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const MyCircularIndicator();
                        }

                        List<HistoryModel> histories = snapshot.data;
                        return HistoryPartWidget(
                          histories: histories,
                          onTap: (histories) => onTap(histories),
                        );
                      },
                    ),
                  ),
                ],
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
          customer.birth ?? DateTime.now(),
        ).difference(DateTime.now()).inDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(shortenedNameText(customer.name), style: TextStyles.bold14),
            width(5),
            sexIcon(customer.sex),
            width(5),
            Text(
              '${customer.birth?.formattedBirth} ${calculateAge(customer.birth ?? DateTime.now())}세/',
            ),
            width(3),
          ],
        ),
        Text(
          '상령일: ${getInsuranceAgeChangeDate(customer.birth ?? DateTime.now()).formattedDate}',
          style: TextStyle(
            color: difference <= 90 ? Colors.red : Colors.black87,
          ),
        ),
        if (customer.recommended != '') Text(customer.recommended),
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
