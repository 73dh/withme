import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/model/history_model.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/is_need_new_history.dart';
import '../components/blinking_calendar_icon.dart';
import '../core_presentation_import.dart';

class HistoryPartWidget extends StatelessWidget {
  final List<HistoryModel> histories;
  final void Function(List<HistoryModel> histories) onTap;
  final String sex;

  const HistoryPartWidget({
    super.key,
    required this.histories,
    required this.onTap,
    required this.sex,
  });

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool showReminderAnimation = isNeedNewHistory(histories);

    // 최근 1개 또는 최대 2개 보여주기
    List<HistoryModel> displayHistories =
        showReminderAnimation
            ? [histories.last]
            : histories.length <= 2
            ? histories
            : histories.sublist(histories.length - 2);

    // 오래된 순 정렬
    displayHistories.sort((a, b) => a.contactDate.compareTo(b.contactDate));

    return GestureDetector(
      onTap: () => onTap(histories),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < displayHistories.length; i++)
            _buildHistoryBox(
              context,
              history: displayHistories[i],
              isRecent: i == displayHistories.length - 1,
              historyNumber:
                  histories.length - (displayHistories.length - 1) + i,
              colorScheme: colorScheme,
            ),
          if (showReminderAnimation) ...[
            height(3),
            BlinkingCalendarIcon(sex: sex, size: 25),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryBox(
    BuildContext context, {
    required HistoryModel history,
    required bool isRecent,
    required int historyNumber,
    required ColorScheme colorScheme,
  }) {
    final theme = Theme.of(context);

    final TextStyle contentStyle =
        isRecent
            ? theme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            )
            : theme.textTheme.labelSmall!.copyWith(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
            );

    final TextStyle dateStyle =
        isRecent
            ? theme.textTheme.labelSmall!.copyWith(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
            )
            : theme.textTheme.labelSmall!.copyWith(
              fontSize: 8,
              color: colorScheme.outline,
            );

    final Color numberColor =
        isRecent
            ? (sex == '남' ? ColorStyles.manColor : ColorStyles.womanColor)
            : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: numberColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$historyNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: numberColor,
                ),
              ),
            ),
            width(3),
            Text(history.contactDate.formattedBirth, style: dateStyle),
          ],
        ),
        height(2),
        Text(
          history.content,
          style: contentStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
