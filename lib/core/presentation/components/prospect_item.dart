import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/prospect_item_icon.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/presentation/widget/item_container.dart';
import 'package:withme/core/utils/calculate_age.dart';
import 'package:withme/core/utils/calculate_insurance_age.dart';
import 'package:withme/core/utils/days_until_insurance_age.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/shortened_text.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../di/setup.dart';
import '../../ui/color/color_style.dart';
import '../widget/insurance_age_widget.dart';
import '../widget/rotating_dots.dart';
import 'circle_item.dart';
import 'sex_widget.dart';
import 'width_height.dart';
import '../../ui/text_style/text_styles.dart';
import '../../../domain/model/customer_model.dart';
import '../../../presentation/home/prospect_list/prospect_list_view_model.dart';

class ProspectItem extends StatelessWidget {
  final String userKey;
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const ProspectItem({
    super.key,
    required this.userKey,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<HistoryModel> histories = customer.histories;
    histories.sort((a, b) => a.contactDate.compareTo(b.contactDate));
    return IntrinsicHeight(
      child: StreamBuilder(
        stream: getIt<HistoryUseCase>().call(
          usecase: GetHistoriesUseCase(
            userKey: userKey,
            customerKey: customer.customerKey,
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          List<HistoryModel> histories = snapshot.data!;
          histories.sort((a, b) => a.contactDate.compareTo(b.contactDate));

          return ItemContainer(
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
                    ProspectItemIcon(
                      number: histories.length,
                      sex: customer.sex,
                      backgroundImagePath: 'assets/icons/pool_person.png',
                    ),
                    // CircleItem(number: histories.length, sex: customer.sex),
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
          );
        },
      ),
    );
  }

  Widget _namePart() {
    DateTime? birthDate = customer.birth?.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              shortenedNameText(customer.name, length: 6),
              style: TextStyles.bold14.copyWith(color: Colors.black87),
            ),
            width(6),
            if (birthDate != null)
              Text(
                '${birthDate.formattedBirth} (${calculateAge(birthDate)}세)',
                style: TextStyles.normal12.copyWith(color: Colors.grey[700]),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (birthDate != null) InsuranceAgeWidget(birthDate: birthDate),

        if (customer.recommended.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '소개자: ${customer.recommended}',
            style: TextStyles.normal12.copyWith(color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }
}
