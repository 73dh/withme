import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/presentation/todo/common_todo_list.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../di/setup.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';

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
    final DateTime? birthDate = customer.birth?.toLocal();
    final info = customer.insuranceInfo;

    return IntrinsicHeight(
      child: StreamBuilder<List<HistoryModel>>(
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
          if (!snapshot.hasData) return const SizedBox.shrink();

          final histories =
              snapshot.data!
                ..sort((a, b) => a.contactDate.compareTo(b.contactDate));

          return ItemContainer(
            backgroundColor: info.isUrgent ? ColorStyles.isUrgentColor : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileColumn(customer),
                width(12),
                _buildNamePart(
                  birthDate: birthDate,
                  difference: info.difference,
                  isUrgent: info.isUrgent,
                  insuranceChangeDate: info.insuranceChangeDate,
                ),
                width(10),
                Expanded(
                  child: HistoryPartWidget(
                    histories: histories,
                    onTap: onTap,
                    sex: customer.sex,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileColumn(CustomerModel customer) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          customer.registeredDate.formattedYearAndMonth,
          style: TextStyles.normal12,
        ),
        height(3),
        SexIconWithBirthday(
          birth: customer.birth,
          sex: customer.sex,
          backgroundImagePath:
              customer.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon,
        ),
      ],
    );
  }

  Widget _buildNamePart({
    required DateTime? birthDate,
    required int? difference,
    required bool isUrgent,
    required DateTime? insuranceChangeDate,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
              if (customer.todos.isNotEmpty) ...[
                width(3),

                    SizedBox(
                      width: 50,
                      child: StreamTodoText(
                        todoList: customer.todos,
                        sex: customer.sex,
                      ),
                    ),
                    TodoCountIcon(
                      todos: customer.todos,
                      sex: customer.sex,
                      iconSize: 18,
                    ),



              ],
            ],
          ),
          height(6),
          if (birthDate != null &&
              difference != null &&
              insuranceChangeDate != null)
            InsuranceAgeWidget(
              difference: difference,
              isUrgent: isUrgent,
              insuranceChangeDate: insuranceChangeDate,
            ),
          if (customer.recommended.isNotEmpty) ...[
            height(2),
            Text(
              '소개자: ${customer.recommended}',
              style: TextStyles.normal12.copyWith(color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }
}
