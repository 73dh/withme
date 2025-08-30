import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/birthday_badge.dart';
import 'package:withme/core/presentation/components/first_name_icon.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
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
    final textTheme = theme.textTheme;
    final info = customer.insuranceInfo;

    // TodoViewModel을 고객별로 생성 (Provider로 관리 추천)
    final todoViewModel = TodoViewModel(
      userKey: userKey,
      customerKey: customer.customerKey,
    );

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
                      ? colorScheme.tertiaryContainer
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
                      height(4),
                      FirstNameIcon(
                        customer: customer,
                        size: 40,
                        todoCount: todos.length, // ✅ Todo 개수 전달
                      ),
                      // ProspectItemIcon(customer: customer),
                    ],
                  ),

                  width(12),

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
                                  width(5),
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

                            /// 할일목록 표시
                            // if (todos.isNotEmpty) ...[
                            //   width(6),
                            //   // ✅ 고정폭 Container로 텍스트 위치 고정
                            //   StreamTodoText(
                            //     todoList: todos.map((t) => t.content).toList(),
                            //     style: Theme.of(
                            //       context,
                            //     ).textTheme.bodySmall?.copyWith(
                            //       color: getSexIconColor(
                            //         customer.sex,
                            //         colorScheme,
                            //       ),
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            //   width(4),
                            //   // TodoCountIcon 위치 고정
                            //   SizedBox(
                            //     width: 18,
                            //     child: TodoCountIcon(
                            //       todos: todos,
                            //       sex: customer.sex,
                            //       iconSize: 18,
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),

                        height(2),

                        Row(
                          children: [
                            // 생년월일
                            if (customer.birth != null)
                              Text(
                                '${customer.birth!.formattedBirth} (${calculateAge(customer.birth!)}세)',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            width(5),
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
                        height(2),
                        // 소개자
                        if (customer.recommended.isNotEmpty)
                          Text(
                            '[소개자] ${customer.recommended}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  width(8),

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
