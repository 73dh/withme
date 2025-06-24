import 'package:flutter/material.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/history_part_widget.dart';
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
                    customer.birth != null
                        ? '생년월일: ${customer.birth!.formattedDate} (${calculateAge(customer.birth!)}세)'
                        : '생년월일 정보 없음',
                  ),
                  height(5),
                  Text(
                    '상령일: ${customer.birth!.formattedDate} (${daysUntilInsuranceAgeChange(customer.birth!)}일 남음)',
                  ),
                  if (customer.recommended != '') Text(customer.recommended),
                ],
              ),
              StreamBuilder<List<HistoryModel>>(
                stream: viewModel.getHistories(UserSession.userId, customer.customerKey),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const MyCircularIndicator();
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
            ],
          ),
        ),
      ),
    );
  }
}
