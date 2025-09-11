import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/birthday_badge.dart';
import 'package:withme/core/presentation/components/first_name_icon.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../di/setup.dart';
import '../core_presentation_import.dart';
import '../todo/todo_view_model.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final info = customer.insuranceInfo;

    // TodoViewModel 초기화
    final todoViewModel = TodoViewModel(
      userKey: userKey,
      customerKey: customer.customerKey,
    )..loadTodos(customer.todos);

    return StreamBuilder<List<HistoryModel>>(
      stream: getIt<HistoryUseCase>().call(
        usecase: GetHistoriesUseCase(
          userKey: userKey,
          customerKey: customer.customerKey,
        ),
      ),
      builder: (context, snapshot) {
        final histories = snapshot.data ?? [];

        return AnimatedBuilder(
          animation: todoViewModel,
          builder: (context, _) {
            final todos = todoViewModel.todoList;

            return ItemContainer(
              backgroundColor: info.isUrgent
                  ? colorScheme.tertiaryContainer
                  : colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ✅ 위쪽 정렬
                children: [
                  _buildIconColumn(theme, todos),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoColumn(theme, colorScheme)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
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
        );
      },
    );
  }

  Widget _buildIconColumn(ThemeData theme, List todos, ) {
    final hasOverdue = todos.any((t) => t.isOverdue); // ✅ 여기서 계산
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          customer.registeredDate.formattedYearAndMonth,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        FirstNameIcon(
          customer: customer,
          size: 38,
          todoCount: todos.length,
          hasOverdueTodo: hasOverdue, // ✅ 전달
        ),
      ],
    );
  }

  Widget _buildInfoColumn(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이름 + Memo + Birthday
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    shortenedNameText(customer.name, length: 6),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 5),
                  if (customer.memo.isNotEmpty)
                    Icon(
                      Icons.feed_outlined,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  BirthdayBadge(
                    birth: customer.birth,
                    iconSize: 16,
                    textSize: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // 생년월일 + 상령일
        Row(
          children: [
            if (customer.birth != null)
              Text(
                '${customer.birth!.formattedBirth} (${calculateAge(customer.birth!)}세)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(width: 5),
            if (customer.insuranceInfo.difference != null &&
                customer.insuranceInfo.insuranceChangeDate != null)
              InsuranceAgeWidget(
                difference: customer.insuranceInfo.difference!,
                isUrgent: customer.insuranceInfo.isUrgent,
                insuranceChangeDate:
                customer.insuranceInfo.insuranceChangeDate!,
                colorScheme: colorScheme,
              ),
          ],
        ),
        const SizedBox(height: 2),
        // 소개자
        if (customer.recommended.isNotEmpty)
          Text(
            '[소개자] ${customer.recommended}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
