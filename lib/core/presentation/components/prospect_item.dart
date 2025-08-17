import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../di/setup.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';
import '../todo/todo_view_model.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../di/setup.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';
import '../todo/todo_view_model.dart';

import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../di/setup.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';
import '../todo/todo_view_model.dart';

import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../di/setup.dart';
import '../../utils/core_utils_import.dart';
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

    // TodoViewModel에서 고객별 실시간 todo 구독
    final todoViewModel = getIt<TodoViewModel>();
    todoViewModel.initializeTodos(
      userKey: userKey,
      customerKey: customer.customerKey,
    );

    return StreamBuilder<List<TodoModel>>(
      stream: todoViewModel.todoStream,
      builder: (context, todoSnapshot) {
        final todos = todoSnapshot.data ?? customer.todos;

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
              backgroundColor: info.isUrgent
                  ? colorScheme.errorContainer
                  : colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 등록일 + 성별 아이콘
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        customer.registeredDate.formattedYearAndMonth,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SexIconWithBirthday(
                        birth: customer.birth,
                        sex: customer.sex,
                        backgroundImagePath:
                        customer.sex == '남'
                            ? IconsPath.manIcon
                            : IconsPath.womanIcon,
                        size: 35,
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // 이름, 생년월일, 상령일, 할일
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름 + 할일 Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shortenedNameText(customer.name, length: 6),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (todos.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 30,
                                child: StreamTodoText(
                                  todoList: todos,
                                  sex: customer.sex,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TodoCountIcon(
                                todos: todos,
                                sex: customer.sex,
                                iconSize: 18,
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

