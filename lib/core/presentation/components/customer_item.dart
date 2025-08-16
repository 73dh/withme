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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final birthDate = customer.birth;
    final info = customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return StreamBuilder<List<PolicyModel>>(
      stream: viewModel.getPolicies(customerKey: customer.customerKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) log(snapshot.error.toString());
        if (!snapshot.hasData) return const SizedBox.shrink();

        final policies = snapshot.data!;
        return ItemContainer(
          backgroundColor:
              isUrgent ? ColorStyles.isUrgentColor : colorScheme.surfaceVariant,
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
                        _buildNameRow(
                          customer,
                          birthDate,
                          difference,
                          insuranceChangeDate,
                          isUrgent,
                          theme,
                          colorScheme,
                        ),
                        _buildPolicyList(policies, theme, colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: HistoryPartWidget(
                  histories: customer.histories,
                  onTap: onTap,
                  sex: customer.sex,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameRow(
    CustomerModel customer,
    DateTime? birthDate,
    int? difference,
    DateTime? insuranceChangeDate,
    bool isUrgent,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final iconPath =
        customer.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon;

    if (birthDate == null) {
      return Row(
        children: [
          Text(
            shortenedNameText(customer.name, length: 6),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          width(5),
          Text(
            '정보 없음',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          width(3),
          Text(
            customer.recommended.isNotEmpty ? customer.recommended : '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
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
          isShowDay: true,
        ),
        width(3),
        Text(
          shortenedNameText(customer.name, length: 6),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        width(3),
        Text(
          '${calculateAge(birthDate)}세 /',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        width(3),
        if (difference != null &&
            difference >= 0 &&
            insuranceChangeDate != null)
          InsuranceAgeWidget(
            difference: difference,
            isUrgent: isUrgent,
            insuranceChangeDate: insuranceChangeDate,
          ),

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

  Widget _buildPolicyList(
    List<PolicyModel> policies,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final showPrev = policies.length > 1;
    final recentPolicies =
        showPrev
            ? policies.reversed.take(1).toList().reversed.toList()
            : policies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPrev)
          Text(
            '...prev',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        height(2),
        ...recentPolicies.map((policy) {
          final isCancelled =
              policy.policyState == PolicyState.cancelled.label ||
              policy.policyState == PolicyState.lapsed.label;
          final premiumText = numFormatter.format(
            int.tryParse(policy.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                policy.startDate?.formattedBirth ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  policy.productCategory,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              width(5),
              Text(
                premiumText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCancelled ? Colors.red : colorScheme.onSurface,
                  fontWeight: isCancelled ? FontWeight.bold : FontWeight.normal,
                  decoration:
                      isCancelled
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  decorationColor: isCancelled ? Colors.red : null,
                  decorationThickness: isCancelled ? 2 : null,
                ),
              ),
              width(5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  ' (${policy.paymentMethod})',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
