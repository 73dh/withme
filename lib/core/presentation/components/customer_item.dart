import 'dart:developer';

import 'package:withme/core/domain/enum/policy_state.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/extension/number_format.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../presentation/home/customer_list/customer_list_view_model.dart';
import '../../di/setup.dart';
import '../../utils/calculate_age.dart';
import '../../utils/is_birthday_within_7days.dart';
import '../../utils/shortened_text.dart';
import '../core_presentation_import.dart';
import 'customer_item_icon.dart';

class CustomerItem extends StatelessWidget {
  final CustomerModel customer;
  final void Function(List<HistoryModel> histories) onTap;

  const CustomerItem({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerListViewModel>();
    final birthDate = customer.birth;

    final info = customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return StreamBuilder(
      stream: viewModel.getPolicies(customerKey: customer.customerKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        List<PolicyModel> policies = snapshot.data!;
        return ItemContainer(
          backgroundColor: isUrgent ? ColorStyles.isUrgentColor : null,
          child: Stack(
            children: [
              Row(
                children: [
                  CustomerItemIcon(customer: customer),
                  width(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _namePart(
                          context,
                          customer,
                          birthDate,
                          difference,
                          isUrgent,
                          insuranceChangeDate,
                        ),
                        _policyPart(policies),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: HistoryPartWidget(
                  histories: customer.histories,
                  onTap: (histories) => onTap(histories),
                  sex: customer.sex,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _namePart(
      BuildContext context,
    CustomerModel customer,
    DateTime? birthDate,
    int? difference,
    bool isUrgent,
    DateTime? insuranceChangeDate,
  ) {
    final iconPath =
        customer.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon;
    if (birthDate == null) {
      return Row(
        children: [
          Text(
            shortenedNameText(customer.name, length: 6),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          width(5),
          const Text('정보 없음'),
          width(3),
          Text(customer.recommended.isNotEmpty ? customer.recommended : ''),
        ],
      );
    }

    return Row(
      children: [
        SexIconWithBirthday(
          birth: birthDate,
          sex: customer.sex,
          backgroundImagePath: iconPath,
          size: 20,
          isShowDay: false,
        ),
        width(3),
        Text(
          shortenedNameText(customer.name, length: 6),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        width(5),
        Text('${calculateAge(birthDate)}세/'),
        width(3),
        if (difference != null &&
            difference >= 0 &&
            insuranceChangeDate != null)
          InsuranceAgeWidget(
            difference: difference,
            isUrgent: isUrgent,
            insuranceChangeDate: insuranceChangeDate,
          ),
        if (isBirthdayWithin7Days(birthDate)) ...[
          const SizedBox(width: 4),
          const Icon(Icons.cake_rounded, color: Colors.pinkAccent, size: 16),
          const SizedBox(width: 2),
          if (getBirthdayCountdown(birthDate) != 0)
            Text(
              '(D-${getBirthdayCountdown(birthDate)})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.pinkAccent),
            ),
        ],
        if (difference == null || difference < 0) const SizedBox.shrink(),
        width(5),
        SizedBox(
          width: 30,
          child: StreamTodoText(todoList: customer.todos, sex: customer.sex),
        ),
        if (customer.todos.isNotEmpty)
          TodoCountIcon(todos: customer.todos, sex: customer.sex, iconSize: 20),
      ],
    );
  }

  Widget _policyPart(List<PolicyModel> policies) {
    final bool showPrev = policies.length > 1;

    // 가장 최근 1개
    final List<PolicyModel> recentPolicies =
        showPrev
            ? policies.reversed.take(1).toList().reversed.toList()
            : policies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPrev)
          const Text(
            '...prev',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ...recentPolicies.map((e) {
          final isCancelled =
              e.policyState == PolicyState.cancelled.label ||
              e.policyState == PolicyState.lapsed.label;

          final premiumText = numFormatter.format(
            int.tryParse(e.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.startDate?.formattedBirth ?? ''),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(e.productCategory, overflow: TextOverflow.ellipsis),
              ),
              width(5),
              Text(
                premiumText,
                style: TextStyle(
                  color: isCancelled ? Colors.red : null,
                  fontWeight: isCancelled ? FontWeight.bold : null,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                  decorationColor: isCancelled ? Colors.red : null,
                  decorationThickness: isCancelled ? 2 : null,
                ),
              ),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  ' (${e.paymentMethod})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
