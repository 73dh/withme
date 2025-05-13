import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/ui/icon/const.dart';
import 'package:withme/core/utils/calculate_age.dart';
import 'package:withme/core/utils/calculate_insurance_age.dart';
import 'package:withme/core/utils/days_until_insurance_age.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/presentation/home/prospect/prospect_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/widget/circle_item.dart';
import '../../../../core/presentation/widget/sex_widget.dart';
import '../../../../core/presentation/widget/width_height.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../domain/model/customer_model.dart';

class ProspectCard extends StatelessWidget {
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const ProspectCard({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: StreamBuilder(
        stream: getIt<ProspectViewModel>().fetchHistories(customer.customerKey),
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
                    Expanded(child: _historyPart(histories)),
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
            Text(customer.name, style: TextStyles.bold14),
            width(5),
            sexIcon(customer.sex),
            width(5),
            (isDate != null)
                ? Text(
                  '${calculateAge(customer.birth!)}세 [Insure: ${calculateInsuranceAge(customer.birth!)}]',
                )
                : const SizedBox.shrink(),
          ],
        ),
        (customer.birth?.toLocal() != null)
            ? Text(
              '상령일: ${getInsuranceAgeChangeDate(customer.birth!).formattedDate}',
              style: TextStyle(
                color: difference <= 90 ? Colors.red : Colors.black87,
              ),
            )
            : const SizedBox.shrink(),

        Text(customer.recommended != '' ? customer.recommended : '소개자 없음'),
      ],
    );
  }

  Widget _historyPart(List<HistoryModel> histories) {
    if (histories.isNotEmpty) {
      return GestureDetector(
        onTap: () => onTap(histories),
        // () => onEvent(
        //   PoolEvent.getHistories(customerKey: customer.customerKey),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (histories.length >= 2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    histories[histories.length - 2].contactDate.formattedDate,
                    style: TextStyles.normal12,
                  ),
                  Text(
                    histories[histories.length - 2].content,
                    style: TextStyles.bold12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            height(3),
            Text(
              histories[histories.length - 1].contactDate.formattedDate,
              style: TextStyles.normal12,
            ),
            Text(
              histories[histories.length - 1].content,
              style: TextStyles.bold12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
