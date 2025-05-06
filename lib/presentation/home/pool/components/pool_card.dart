import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/widget/circle_item.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/presentation/home/pool/pool_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/ui/text_style/text_styles.dart';
import '../../../../core/widget/width_height.dart';
import '../../../../domain/model/customer_model.dart';

class PoolCard extends StatelessWidget {
  final CustomerModel customer;

  const PoolCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: StreamBuilder(
        stream: getIt<PoolViewModel>().getHistories(customer.customerKey),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            log(snapshot.error.toString());
          }
          if(snapshot.hasData){
            List<HistoryModel> histories=snapshot.data;
          return Container(
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
                      CircleItem(number:histories.length,color: Colors.grey[300],),
                    ],
                  ),
                  width(20),
                  _namePart(),
                  const Spacer(),
                  _historyPart(histories),
                ],
              ),
            ),
          );
          }else{
            return SizedBox.shrink();
          }

        }
      ),
    );
  }



  Widget _namePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(customer.name, style: TextStyles.bold14),
        Text(customer.recommended != '' ? customer.recommended : '소개자 없음'),
      ],
    );
  }

  Widget _historyPart(List<HistoryModel> histories) {
    if (histories.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (histories.length >= 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  histories[histories.length-2].contactDate.formattedDate,
                  style: TextStyles.normal12,
                ),
                Text(
                  histories[histories.length - 2].content,
                  style: TextStyles.bold12,overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          const SizedBox(height: 3),
          Text(
                            histories[histories.length - 1]
                .contactDate
                .formattedDate,
            style: TextStyles.normal12,
          ),
          Text(
            histories[histories.length - 1].content,
            style: TextStyles.bold12,overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
