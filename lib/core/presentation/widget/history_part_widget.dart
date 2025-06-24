import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/model/history_model.dart';
import '../../ui/text_style/text_styles.dart';
import '../core_presentation_import.dart';

class HistoryPartWidget extends StatelessWidget {
  final List<HistoryModel> histories;
  final void Function(List<HistoryModel> histories) onTap;

  const HistoryPartWidget({
    super.key,
    required this.histories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) return const SizedBox.shrink();

    final int count = histories.length;
    final recent = histories[count - 1];
    final previous = count >= 2 ? histories[count - 2] : null;

    return GestureDetector(
      onTap: () => onTap(histories),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
        child: Align(
          key: ValueKey(histories.length),
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (previous != null)
                  _buildHistoryBox(history: previous, isRecent: false),
                if (previous != null) height(6),
                _buildHistoryBox(history: recent, isRecent: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryBox({
    required HistoryModel history,
    required bool isRecent,
  }) {
    final Color backgroundColor =
        isRecent ? Colors.blue.shade50 : Colors.grey.shade200;

    final TextStyle contentStyle =
        isRecent
            ? TextStyles.normal12.copyWith(fontWeight: FontWeight.w500)
            : TextStyles.normal10.copyWith(color: Colors.grey[700]);

    final TextStyle dateStyle =
        isRecent
            ? TextStyles.normal10.copyWith(color: Colors.grey[700])
            : TextStyles.normal9.copyWith(color: Colors.grey[600]);

    final Color dotColor = isRecent ? Colors.blueAccent : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 날짜 + 도트 라인
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(history.contactDate.formattedDate, style: dateStyle),
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
