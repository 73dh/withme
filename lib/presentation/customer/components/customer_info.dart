import 'package:withme/domain/model/customer_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../customer_view_model.dart';
import 'package:withme/domain/model/customer_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../customer_view_model.dart';

class CustomerInfo extends StatelessWidget {
  final CustomerModel customer;
  final CustomerViewModel viewModel;

  final bool isUrgent;
  final int? difference;
  final DateTime? insuranceChangeDate;

  const CustomerInfo({
    super.key,
    required this.customer,
    required this.viewModel,
    required this.isUrgent,
    required this.difference,
    required this.insuranceChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    final birthDate = customer.birth;
    final colorScheme = Theme.of(context).colorScheme;

    return ItemContainer(
      height: customer.recommended.isEmpty ? 90 : 110,
      backgroundColor: isUrgent ? colorScheme.errorContainer : null, // 기존 isUrgentColor
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          children: [
            /// 왼쪽 고객 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 이름 + 성별 아이콘
                Row(
                  children: [
                    sexIcon(customer.sex, colorScheme), // ColorScheme 기반 sexIcon
                    width(6),
                    Text(
                      shortenedNameText(customer.name),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface, // 다크/라이트 대응
                      ),
                    ),
                  ],
                ),
                height(6),

                /// 생년월일
                Row(
                  children: [
                    Icon(Icons.cake, size: 16, color: colorScheme.onSurfaceVariant),
                    width(4),
                    Text(
                      birthDate != null
                          ? '${birthDate.formattedBirth} (${calculateAge(birthDate)}세)'
                          : '정보 없음',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                height(4),

                /// 상령일 (D-xxx)
                if (birthDate != null &&
                    difference != null &&
                    difference! >= 0 &&
                    insuranceChangeDate != null)
                  InsuranceAgeWidget(
                    difference: difference!,
                    isUrgent: isUrgent,
                    insuranceChangeDate: insuranceChangeDate!, colorScheme: colorScheme,
                  ),

                /// 소개자
                if (customer.recommended.isNotEmpty) ...[
                  height(4),
                  Text(
                    '소개자: ${customer.recommended}',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),

            const Spacer(),

            /// 오른쪽 이력 표시
            StreamBuilder<List<HistoryModel>>(
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
                  onTap: (histories) async {
                    await popupAddHistory(
                      context: context,
                      histories: histories,
                      customer: customer,
                      initContent: HistoryContent.title.toString(),
                    );
                  },
                  sex: customer.sex,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
