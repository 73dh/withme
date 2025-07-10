import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/item_container.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/history_part_widget.dart';
import '../../../core/presentation/widget/insurance_age_widget.dart';
import '../../../core/presentation/components/rotating_dots.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../customer_view_model.dart';

class CustomerInfo extends StatelessWidget {
  final CustomerModel customer;
  final CustomerViewModel viewModel;

  const CustomerInfo({
    super.key,
    required this.customer,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final birthDate = customer.birth;

    return
      ItemContainer(height: 95, child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 왼쪽 고객 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 이름 + 성별 아이콘
              Row(
                children: [
                  Text(
                    shortenedNameText(customer.name),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  width(6),
                  sexIcon(customer.sex),
                ],
              ),
              height(6),

              /// 생년월일
              Row(
                children: [
                  const Icon(Icons.cake, size: 16, color: Colors.grey),
                  width(4),
                  Text(
                    birthDate != null
                        ? '${birthDate.formattedDate} (${calculateAge(birthDate)}세)'
                        : '정보 없음',
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ],
              ),
              height(4),

              /// 상령일
              if (birthDate != null)
                InsuranceAgeWidget(birthDate: birthDate),
              // Row(
              //   children: [
              //     Text(
              //       '상령일: ${getInsuranceAgeChangeDate(birthDate).formattedDate}',
              //       style: TextStyles.normal12.copyWith(
              //         color: isUrgent ? Colors.red : Colors.grey[600],
              //       ),
              //     ),
              //     if (isUrgent) ...[
              //       width(6),
              //       const RotatingDots(
              //         size: 15,
              //         dotBaseSize: 4,
              //         dotPulseRange: 2,
              //         colors: [Colors.red, Colors.blue],
              //       ),
              //     ],
              //   ],
              // ),

              /// 소개자
              if (customer.recommended.isNotEmpty) ...[
                height(4),
                Text(
                  '소개자: ${customer.recommended}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ],
          ),

          // width(8),

          /// 오른쪽 이력 표시
          Expanded(
            child: StreamBuilder<List<HistoryModel>>(
              stream: viewModel.getHistories(
                UserSession.userId,
                customer.customerKey,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const MyCircularIndicator();
                }
                final histories = snapshot.data!;
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
          ),
        ],
      ));

    //   PartBox(
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         /// 왼쪽 고객 정보
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             /// 이름 + 성별 아이콘
    //             Row(
    //               children: [
    //                 Text(
    //                   shortenedNameText(customer.name),
    //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    //                 ),
    //                 width(6),
    //                 sexIcon(customer.sex),
    //               ],
    //             ),
    //             height(6),
    //
    //             /// 생년월일
    //             Row(
    //               children: [
    //                 const Icon(Icons.cake, size: 16, color: Colors.grey),
    //                 width(4),
    //                 Text(
    //                   birthDate != null
    //                       ? '${birthDate.formattedDate} (${calculateAge(birthDate)}세)'
    //                       : '정보 없음',
    //                   style: TextStyle(fontSize: 12, color: Colors.grey[800]),
    //                 ),
    //               ],
    //             ),
    //             height(4),
    //
    //             /// 상령일
    //             if (birthDate != null)
    //               InsuranceAgeWidget(birthDate: birthDate),
    //               // Row(
    //               //   children: [
    //               //     Text(
    //               //       '상령일: ${getInsuranceAgeChangeDate(birthDate).formattedDate}',
    //               //       style: TextStyles.normal12.copyWith(
    //               //         color: isUrgent ? Colors.red : Colors.grey[600],
    //               //       ),
    //               //     ),
    //               //     if (isUrgent) ...[
    //               //       width(6),
    //               //       const RotatingDots(
    //               //         size: 15,
    //               //         dotBaseSize: 4,
    //               //         dotPulseRange: 2,
    //               //         colors: [Colors.red, Colors.blue],
    //               //       ),
    //               //     ],
    //               //   ],
    //               // ),
    //
    //             /// 소개자
    //             if (customer.recommended.isNotEmpty) ...[
    //               height(4),
    //               Text(
    //                 '소개자: ${customer.recommended}',
    //                 style: TextStyle(fontSize: 12, color: Colors.grey[700]),
    //               ),
    //             ],
    //           ],
    //         ),
    //
    //         // width(8),
    //
    //         /// 오른쪽 이력 표시
    //         Expanded(
    //           child: StreamBuilder<List<HistoryModel>>(
    //             stream: viewModel.getHistories(
    //               UserSession.userId,
    //               customer.customerKey,
    //             ),
    //             builder: (context, snapshot) {
    //               if (!snapshot.hasData) {
    //                 return const MyCircularIndicator();
    //               }
    //               final histories = snapshot.data!;
    //               return HistoryPartWidget(
    //                 histories: histories,
    //                 onTap: (histories) {
    //                   popupAddHistory(
    //                     context,
    //                     histories,
    //                     customer,
    //                     HistoryContent.title.toString(),
    //                   );
    //                 },
    //               );
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}