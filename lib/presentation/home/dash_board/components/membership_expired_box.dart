import 'package:flutter/material.dart';

import '../../../../core/presentation/core_presentation_import.dart';

class MembershipExpiredBox extends StatelessWidget {
  const MembershipExpiredBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final warningColor = colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.1), // 연한 배경
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warningColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '유료회원 서비스가 만료되어 고객 추가 등록이 불가합니다.\n멤버십을 갱신해주세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
