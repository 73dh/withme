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
              isUrgent ? colorScheme.errorContainer : colorScheme.surface,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerItemIcon(customer: customer),
              width(6),
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
              HistoryPartWidget(
                histories: customer.histories,
                onTap: onTap,
                sex: customer.sex,
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

    return Row(
      children: [
        // 성별 + 생일 아이콘
        SexIconWithBirthday(
          birth: birthDate,
          sex: customer.sex,
          backgroundImagePath: iconPath,
          size: 23,
          isShowDay: true,
        ),
        width(5),
        // 이름 (아이콘과 바로 붙음)
        Text(
          shortenedNameText(customer.name, length: 6),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        // 나이
        if (birthDate != null)
          Text(
            ' ${calculateAge(birthDate)}세',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),

        // 보험나이 / 상령일
        if (difference != null && insuranceChangeDate != null)
          InsuranceAgeWidget(
            difference: difference,
            isUrgent: isUrgent,
            insuranceChangeDate: insuranceChangeDate,
            colorScheme: colorScheme,
            isCustomerItem: true,
          ),
        const Spacer(),
        // 할일
        if (customer.todos.isNotEmpty) ...[
          StreamTodoText(
            todoList: customer.todos.map((t) => t.content).toList(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: getSexIconColor(customer.sex, colorScheme),
              fontWeight: FontWeight.bold,
            ),
          ),
         width(2),
          TodoCountIcon(todos: customer.todos, sex: customer.sex, iconSize: 18),
        ],
        width(10),
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
          Row(
            children: [
              width(5),
              Text(
                '...prev',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        height(2),
        ...recentPolicies.map((policy) {
          final isCancelled =
              policy.policyState == PolicyStatus.cancelled.label ||
              policy.policyState == PolicyStatus.lapsed.label;
          final premiumText = numFormatter.format(
            int.tryParse(policy.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              width(5),
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
                  color:
                      isCancelled ? colorScheme.error : colorScheme.onSurface,
                  fontWeight: isCancelled ? FontWeight.bold : FontWeight.normal,
                  decoration:
                      isCancelled
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  decorationColor: isCancelled ? colorScheme.error : null,
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
