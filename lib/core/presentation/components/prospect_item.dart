import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/prospect_item_icon.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../di/setup.dart';
import '../../utils/is_birthday_within_7days.dart';
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
    final textTheme = theme.textTheme;
    final info = customer.insuranceInfo;

    // TodoViewModel을 고객별로 생성 (Provider로 관리 추천)
    final todoViewModel = TodoViewModel(
      userKey: userKey,
      customerKey: customer.customerKey,
    );
    final bool hasUpcomingBirthday =
        customer.birth != null && isBirthdayWithin7Days(customer.birth!);
    final int countdown =
        customer.birth != null ? getBirthdayCountdown(customer.birth!) : -1;
    final Color cakeColor = Colors.redAccent;

    // 초기 Firestore todos 넣어주기 (없으면 빈 리스트)
    todoViewModel.loadTodos(customer.todos);

    return AnimatedBuilder(
      animation: todoViewModel,
      builder: (context, _) {
        final todos = todoViewModel.todoList;

        return StreamBuilder<List<HistoryModel>>(
          stream: getIt<HistoryUseCase>().call(
            usecase: GetHistoriesUseCase(
              userKey: userKey,
              customerKey: customer.customerKey,
            ),
          ),
          builder: (context, historySnapshot) {
            final histories = historySnapshot.data ?? [];

            return ItemContainer(
              backgroundColor:
                  info.isUrgent
                      ? colorScheme.secondaryContainer
                      : colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 등록일 + 성별 아이콘
                  Column(
                    mainAxisSize: MainAxisSize.min, // ✅ 높이 자식만큼만
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        customer.registeredDate.formattedYearAndMonth,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ProspectItemIcon(customer: customer),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // 이름, 생년월일, 상령일, 할일
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // ✅ Column 높이 최소화
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름 + 할일 Row
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    shortenedNameText(customer.name, length: 6),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasUpcomingBirthday)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.cake_rounded,
                                          color: cakeColor,
                                          size: 35 * 0.5,
                                        ),
                                        Text(
                                          countdown != 0 ? '-$countdown' : '오늘',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: cakeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            if (todos.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              // ✅ 고정폭 Container로 텍스트 위치 고정
                              StreamTodoText(
                                todoList: todos.map((t) => t.content).toList(),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: getSexIconColor(
                                    customer.sex,
                                    colorScheme,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // TodoCountIcon 위치 고정
                              SizedBox(
                                width: 18,
                                child: TodoCountIcon(
                                  todos: todos,
                                  sex: customer.sex,
                                  iconSize: 18,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 2),

                        // 생년월일
                        if (customer.birth != null)
                          Text(
                            '${customer.birth!.formattedBirth} (${calculateAge(customer.birth!)}세)',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                        // 상령일
                        if (info.difference != null &&
                            info.insuranceChangeDate != null)
                          InsuranceAgeWidget(
                            difference: info.difference!,
                            isUrgent: info.isUrgent,
                            insuranceChangeDate: info.insuranceChangeDate!,
                            colorScheme: colorScheme,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // HistoryPartWidget은 남는 공간 차지
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
}
