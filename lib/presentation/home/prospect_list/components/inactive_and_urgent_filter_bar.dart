import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/presentation/home/prospect_list/prospect_list_view_model.dart';

import '../../../../core/presentation/components/info_icon_with_popup.dart';
import '../../../../core/ui/core_ui_import.dart';

class InactiveAndUrgentFilterBar extends StatelessWidget {
  final bool showInactiveOnly;
  final bool showUrgentOnly;
  final void Function(bool) onInactiveToggle;
  final void Function(bool) onUrgentToggle;

  const InactiveAndUrgentFilterBar({
    super.key,
    required this.showInactiveOnly,
    required this.showUrgentOnly,
    required this.onInactiveToggle,
    required this.onUrgentToggle,
  });

  @override
  Widget build(BuildContext context) {
    final manageDays = getIt<UserSession>().managePeriodDays;
    final urgentDays = getIt<UserSession>().urgentThresholdDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          // 관리기간 초과 필터 버튼 + InfoIcon
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildFilterButton(
                context: context,
                label: '관리기간 경과',
                isActive: showInactiveOnly,
                onTap: () => onInactiveToggle(!showInactiveOnly),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InfoIconWithPopup(
                  message: '마지막 관리일 기준 $manageDays일 이상 경과\n'
                      '기준일은 설정(가망고객관리주기)에서 변경',
                  color: Colors.black45,
                ),
              ),
            ],
          ),

          // 상령일 임박 필터 버튼
          Stack(
            children: [
              _buildFilterButton(
                context: context,
                label: '상령일 도래',
                isActive: showUrgentOnly,
                onTap: () => onUrgentToggle(!showUrgentOnly),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InfoIconWithPopup(
                  message: '상령일 도래고객, 기준일: $manageDays일'
                      '기준일은 설정에서 변경',
                  color: Colors.black45,
                ),
              ),
            ],
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
    return  Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.purple.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isActive ? Colors.purple : Colors.grey[400]!,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.only(left: 8,right: 20, top: 8, bottom: 8),
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


    //   Container(
    //   decoration: BoxDecoration(
    //     color: isActive ? ColorStyles.activeSearchButtonColor : Colors.grey[300],
    //     borderRadius: BorderRadius.circular(5),
    //   ),
    //   child: InkWell(
    //     onTap: onTap,
    //     borderRadius: BorderRadius.circular(5),
    //     child: Padding(
    //       padding: const EdgeInsets.only(left: 8,right: 25, top: 10, bottom: 10),
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Icon(
    //             Icons.check,
    //             color: isActive ? Colors.black87 : Colors.grey,
    //             size: 20,
    //           ),
    //           const SizedBox(width: 8),
    //           Text(label, style: const TextStyle(color: Colors.black87)),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
