import 'package:flutter/material.dart';
import 'package:withme/core/utils/extension/date_time.dart';

import '../../../../core/presentation/widget/circle_item.dart';
import '../../../../core/presentation/widget/sex_widget.dart';
import '../../../../core/presentation/widget/width_height.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../domain/model/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
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
                  number: 1,
                  color: Colors.grey[300],
                ),
              ],
            ),
            width(20),
            _namePart(),
          ],
        ),
      ),
    );
  }

  Widget _namePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(customer.name, style: TextStyles.bold14),
            width(5),
            sexIcon(customer.sex),
          ],
        ),
        Text(customer.recommended != '' ? customer.recommended : '소개자 없음'),
      ],
    );
  }
}
