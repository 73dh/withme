import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';

import '../components/info_icon_with_popup.dart';

class InactiveAndUrgentFilterBar extends StatelessWidget {
  final bool showTodoOnly;
  final bool showInactiveOnly;
  final bool? showUrgentOnly;
  final void Function(bool) onTodoToggle;
  final void Function(bool) onInactiveToggle;
  final void Function(bool)? onUrgentToggle;
  final int todoCount;
  final int inactiveCount;
  final int? urgentCount;

  // Theme 관련 파라미터 추가
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const InactiveAndUrgentFilterBar({
    super.key,
    required this.showTodoOnly,
    required this.showInactiveOnly,
    this.showUrgentOnly,
    required this.onTodoToggle,
    required this.onInactiveToggle,
    this.onUrgentToggle,
    required this.todoCount,
    required this.inactiveCount,
    this.urgentCount,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manageDays = getIt<UserSession>().managePeriodDays;
    final urgentDays = getIt<UserSession>().urgentThresholdDays;

    final bgColor =
        backgroundColor ?? theme.colorScheme.surface;
    final txtColor = textColor ?? theme.colorScheme.onSurfaceVariant;
    final icColor = iconColor ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Wrap(
        spacing: 5,
        children: [
          _buildFilterButton(
            label: '할 일 ($todoCount)',
            isActive: showTodoOnly,
            onTap: () => onTodoToggle(!showTodoOnly),
            bgColor: bgColor,
            txtColor: txtColor,
            activeColor: icColor,
          ),
          _buildFilterButton(
            label: '관리기간 경과 ($inactiveCount)',
            isActive: showInactiveOnly,
            onTap: () => onInactiveToggle(!showInactiveOnly),
            bgColor: bgColor,
            txtColor: txtColor,
            activeColor: icColor,
          ),
          if (showUrgentOnly != null &&
              onUrgentToggle != null &&
              urgentCount != null)
            _buildFilterButton(
              label: '상령일 도래 ($urgentCount)',
              isActive: showUrgentOnly!,
              onTap: () => onUrgentToggle!(!showUrgentOnly!),
              bgColor: bgColor,
              txtColor: txtColor,
              activeColor: icColor,
            ),
          InfoIconWithPopup(
            message: [
              '관리기간: $manageDays일\n',
              if (showUrgentOnly != null) '상령일: $urgentDays일\n',
              '설정에서 변경',
            ].join(', '),
            color: txtColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color bgColor,
    required Color txtColor,
    required Color activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.1) : bgColor,
        border: Border.all(
          color: isActive ? activeColor : Colors.grey[400]!,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(1, 1),
            blurRadius: 1.5,
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
              color: isActive ? activeColor : txtColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
