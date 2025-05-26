import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/text_style/text_styles.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../core/di/setup.dart';
import '../../core/domain/enum/history_content.dart';
import '../../core/presentation/core_presentation_import.dart';
import '../../core/utils/extension/number_format.dart';
import '../../domain/model/customer_model.dart';
import '../../domain/model/history_model.dart';

class CustomerScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const TitleWidget(title: 'Customer Info'),
              height(20),
              PartTitle(
                text: '고객 정보 (등록일: ${customer.registeredDate.formattedDate})',
              ),
              _customerPart(),
              height(15),
              const PartTitle(text: '보험계약 정보'),
              Expanded(
                child: StreamBuilder<List<PolicyModel>>(
                  stream:
                      getIt<PolicyUseCase>().call(
                            usecase: GetPoliciesUseCase(
                              customerKey: customer.customerKey,
                            ),
                          )
                          as Stream<List<PolicyModel>>,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      log(snapshot.error.toString());
                    }
                    if(!snapshot.hasData){
                      return const MyCircularIndicator();
                    }
                      List<PolicyModel> policies = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _policyInfo(policies[index]),
                          );
                        },
                        itemCount: policies.length,
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AddPolicyWidget(
            onTap: () {
              context.push(RoutePath.policy, extra: customer);
            },
            size: 40,
          ),
        ),
      ],
    );
  }

  PartBox _customerPart() {
    return PartBox(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(shortenedNameText(customer.name)),
                      sexIcon(customer.sex),
                    ],
                  ),
                  height(5),
                  Text(
                    '생년월일: ${customer.birth?.formattedDate ?? ''} (${calculateAge(customer.birth!)}세)',
                  ),
                  height(5),
                  Text(
                    '상령일: ${customer.birth!.formattedDate} (${daysUntilInsuranceAgeChange(customer.birth!)}일 남음)',
                  ),
                  if (customer.recommended != '') Text(customer.recommended),
                ],
              ),
              StreamBuilder<List<HistoryModel>>(
                stream: getIt<CustomerViewModel>().getHistories(
                  customer.customerKey,
                ),
                builder: (context, snapshot) {
                  if(!snapshot.hasData){
                    return const MyCircularIndicator();
                  }
                    List<HistoryModel> histories = snapshot.data!;
                    return HistoryPartWidget(
                      histories: histories,
                      onTap: (histories) {
                        popupAddHistory(
                          context,
                          histories,
                          customer,
                          HistoryContent.title.toString(),
                        );
                      },
                    );

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _policyInfo(PolicyModel policy) {
    return PartBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '계약자: ${shortenedNameText(policy.policyHolder, length: 5)}',
                ),

                Row(
                  children: [
                    Text(
                      '피보험자: ${shortenedNameText(policy.insured, length: 5)}',
                    ),
                    sexIcon(policy.insuredSex),
                    width(10),
                    Text(
                      '${policy.insuredBirth?.formattedDate} (${calculateAge(policy.insuredBirth!)}세)',
                    ),
                  ],
                ),
              ],
            ),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('계약일: ${policy.startDate?.formattedDate}'),
                Text('만기일: ${policy.endDate?.formattedDate}'),
              ],
            ),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보험사: ${policy.insuranceCompany}'),
                Text('상품종류: ${policy.productCategory}'),
              ],
            ),
            height(5),
            Text('상품명: ${policy.productName}'),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '보험료: ${numFormatter.format(int.parse(policy.premium))} (${policy.paymentMethod})',
                  style:
                      policy.policyState == '해지'
                          ? TextStyles.cancelStyle
                          : null,
                ),
                Text(
                  policy.policyState,
                  style:
                      policy.policyState == '해지'
                          ? TextStyles.cancelStyle
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
