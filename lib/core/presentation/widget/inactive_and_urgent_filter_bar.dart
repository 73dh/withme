import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';

import '../components/info_icon_with_popup.dart';

class InactiveAndUrgentFilterBar extends StatelessWidget {
  final bool showInactiveOnly;
  final bool? showUrgentOnly;
  final void Function(bool) onInactiveToggle;
  final void Function(bool)? onUrgentToggle;
  final int inactiveCount;
  final int? urgentCount;

  const InactiveAndUrgentFilterBar({
    super.key,
    required this.showInactiveOnly,
    this.showUrgentOnly,
    required this.onInactiveToggle,
    this.onUrgentToggle,
    required this.inactiveCount,
    this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    final manageDays = getIt<UserSession>().managePeriodDays;
    final urgentDays = getIt<UserSession>().urgentThresholdDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Wrap(
        spacing: 5,
        children: [
          _buildFilterButton(
            context: context,
            label: '관리기간 경과 ($inactiveCount)',
            isActive: showInactiveOnly,
            onTap: () => onInactiveToggle(!showInactiveOnly),
          ),
          // 조건부: 상령일 버튼
          if (showUrgentOnly != null &&
              onUrgentToggle != null &&
              urgentCount != null)
            _buildFilterButton(
              context: context,
              label: '상령일 도래 ($urgentCount)',
              isActive: showUrgentOnly!,
              onTap: () => onUrgentToggle!(!showUrgentOnly!),
            ),

          // Info 아이콘
          InfoIconWithPopup(
            message: [
              '관리기간: $manageDays일\n',
              if (showUrgentOnly != null) '상령일: $urgentDays일\n',
              '설정에서 변경 가능',
            ].join(', '),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.purple.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isActive ? Colors.purple : Colors.grey[300]!,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // 희미한 그림자
            offset: Offset(1, 1), // 오른쪽 1px, 아래쪽 1px
            blurRadius: 1.5, // 퍼지는 정도
            spreadRadius: 0, // 그림자가 바깥으로 퍼지지 않게
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.purple : Colors.black54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
