import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/core/utils/show_history_util.dart';

import '../../../domain/model/history_model.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../components/orbiting_dots.dart';
import '../core_presentation_import.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/model/history_model.dart';
import '../../ui/text_style/text_styles.dart';
import '../components/orbiting_dots.dart';
import '../core_presentation_import.dart';
import '../components/stream_todo_text.dart';

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
    final result = showHistoryUtil(histories);
    final recent = result.recent;
    final previous = result.previous;
    final showReminderAnimation = result.showReminder;
    return GestureDetector(
      onTap: () => onTap(histories),
      child: AnimatedSwitcher(
        duration: AppDurations.duration300,
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            key: ValueKey(histories.length),
            alignment: Alignment.topRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (previous != null)
                      _buildHistoryBox(history: previous, isRecent: false),
                    if (previous != null) height(5),
                    _buildHistoryBox(history: recent!, isRecent: true),
                    if (showReminderAnimation) height(5),
                    if (showReminderAnimation) BlinkingCursorIcon(sex: sex),
                  ],
                ),
              ),
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
    final TextStyle contentStyle =
        isRecent
            ? TextStyles.normal10.copyWith(fontWeight: FontWeight.w500)
            : TextStyles.normal9.copyWith(color: Colors.grey[700]);

    final TextStyle dateStyle =
        isRecent
            ? TextStyles.normal9.copyWith(color: Colors.grey[700])
            : TextStyles.normal8.copyWith(color: Colors.grey[600]);

    final Color dotColor =
        isRecent
            ? switch (sex) {
              '남' => ColorStyles.manColor,
              _ => ColorStyles.womanColor,
            }
            : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            width(5),
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
