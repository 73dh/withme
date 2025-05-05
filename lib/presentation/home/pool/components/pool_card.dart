import 'package:flutter/material.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/widget/circle_item.dart';

import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../core/widget/width_height.dart';
import '../../../../domain/model/customer.dart';

class PoolCard extends StatelessWidget {
  final Customer customer;

  const PoolCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // 그림자 색상
              offset: const Offset(4, 4), // x, y 방향으로 이동 (오른쪽 아래)
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
                  Text(customer.registeredDate.formattedMonth,style: TextStyles.normal12,),
                  height(5),
                  CircleItem(number: customer.histories.length,color: Colors.grey[300],),
                ],
              ),
              width(20),
              _namePart(),
              const Spacer(),
              _historyPart(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _namePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(customer.name, style: TextStyles.bold14),
        Text(customer.recommended != 'N' ? customer.recommended : '소개자 없음'),
      ],
    );
  }

  Widget _historyPart() {
    if (customer.histories.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (customer.histories.length >= 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customer
                      .histories[customer.histories.length - 2]
                      .contactDate
                      .formattedDate,
                  style: TextStyles.normal12,
                ),
                Text(
                  customer.histories[customer.histories.length - 2].content,
                  style: TextStyles.bold12,overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          const SizedBox(height: 3),
          Text(
            customer
                .histories[customer.histories.length - 1]
                .contactDate
                .formattedDate,
            style: TextStyles.normal12,
          ),
          Text(
            customer.histories[customer.histories.length - 1].content,
            style: TextStyles.bold12,overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
