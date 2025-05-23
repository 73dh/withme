import 'package:flutter/material.dart';
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
    if (histories.isNotEmpty) {
      return GestureDetector(
        onTap: () => onTap(histories),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (histories.length >= 2)
              Column(
          crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    histories[histories.length - 2].contactDate.formattedDate,
                    style: TextStyles.normal12,
                  ),
                  Text(
                    histories[histories.length - 2].content,
                    style: TextStyles.bold12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            height(3),
            Text(
              histories[histories.length - 1].contactDate.formattedDate,
              style: TextStyles.normal12,
            ),
            Text(
              histories[histories.length - 1].content,
              style: TextStyles.bold12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
