import 'package:flutter/material.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/model/history_model.dart';
import '../../ui/text_style/text_styles.dart';
import '../components/orbiting_dots.dart';
import '../components/jumping_dots.dart';
import '../core_presentation_import.dart';
import '../components/blinking_dots.dart';

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

    final now = DateTime.now();
    final isOld = now.difference(recent.contactDate).inDays >= 60;

    return GestureDetector(
      onTap: () => onTap(histories),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Align(
          key: ValueKey(histories.length),
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (previous != null)
                  _buildHistoryBox(history: previous, isRecent: false),
                if (previous != null) height(6),
                _buildHistoryBox(
                  history: recent,
                  isRecent: true,
                  showAnimatedDot: isOld,
                ),
                if (isOld) height(6),
                if (isOld) const JumpingDots(), // 오래된 경우 점프 애니메이션 추가
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
    bool showAnimatedDot = false,
  }) {
    final TextStyle contentStyle = isRecent
        ? TextStyles.normal10.copyWith(fontWeight: FontWeight.w500)
        : TextStyles.normal9.copyWith(color: Colors.grey[700]);

    final TextStyle dateStyle = isRecent
        ? TextStyles.normal9.copyWith(color: Colors.grey[700])
        : TextStyles.normal8.copyWith(color: Colors.grey[600]);

    final Color dotColor = isRecent ? Colors.blueAccent : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showAnimatedDot)
              const OrbitingDots(

              )
            else
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            if (!showAnimatedDot) width(6),
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