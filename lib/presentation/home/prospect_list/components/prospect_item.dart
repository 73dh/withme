import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/utils/calculate_age.dart';
import 'package:withme/core/utils/calculate_insurance_age.dart';
import 'package:withme/core/utils/days_until_insurance_age.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/shortened_text.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/components/circle_item.dart';
import '../../../../core/presentation/components/sex_widget.dart';
import '../../../../core/presentation/components/width_height.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../domain/model/customer_model.dart';
import '../prospect_list_view_model.dart';

class ProspectItem extends StatelessWidget {
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const ProspectItem({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: StreamBuilder(
        stream: getIt<ProspectListViewModel>().fetchHistories(
          customer.customerKey,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<HistoryModel> histories = snapshot.data;
            histories.sort((a, b) => a.contactDate.compareTo(b.contactDate));
            return Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          customer.registeredDate.formattedMonth,
                          style: TextStyles.normal12,
                        ),
                        height(5),
                        CircleItem(
                          number: histories.length,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    width(20),
                    _namePart(),
                    const Spacer(),
                    Expanded(
                      child: HistoryPartWidget(
                        histories: histories,
                        onTap: (histories) => onTap(histories),
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
      ),
    );
  }

  Widget _namePart() {
    DateTime? isDate = customer.birth?.toLocal();
    int difference =
        customer.birth != null
            ? getInsuranceAgeChangeDate(
              customer.birth!,
            ).difference(DateTime.now()).inDays
            : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(shortenedNameText(customer.name), style: TextStyles.bold14),
            width(5),
            sexIcon(customer.sex),
            width(5),
            (isDate != null)
                ? Text(
                  '${calculateAge(customer.birth!)}세/보험: ${calculateInsuranceAge(customer.birth!)}세',
                )
                : const SizedBox.shrink(),
          ],
        ),
        Text(
          customer.birth?.toLocal() != null
              ? '상령일: ${getInsuranceAgeChangeDate(customer.birth!).formattedDate}'
              : '',
          style: TextStyle(
            color: difference <= 90 ? Colors.red : Colors.black87,
          ),
        ),
        Text(customer.recommended != '' ? customer.recommended : ''),
      ],
    );
  }
}
