import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/shared_pref_value.dart';

import '../../presentation/core_presentation_import.dart';
import 'free_count.dart';

const String adminEmail = 'kdaehee@gmail.com';

Widget styledInfoText(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        TextSpan(
          style: textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: colorScheme.onSurface.withValues(
              alpha: 0.9,
            ), // withOpacity → withValues
          ),
          children: [
            const TextSpan(
              text: '이 App은 가망고객을 발굴한 후,\n고객을 손쉽게 체계적으로 관리할 수 있습니다.\n\n',
            ),
            const TextSpan(text: '관리주기 설정 '),
            TextSpan(
              text: '(기본 ${SharedPrefValue.managePeriodDays}일), ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const TextSpan(text: '상령일'),
            TextSpan(
              text: ' (기본 ${SharedPrefValue.urgentThresholdDays}일) ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const TextSpan(text: '관리 설정을 통한, 주기적, 일상적 고객 관리가 가능하도록 하였으며,\n\n'),
            const TextSpan(text: '가망고객수의 중요도를 고려하여 고객 Pool 관리를 위한 목표를 설정하여'),
            TextSpan(
              text: ' (기본 ${SharedPrefValue.targetProspectCount}명), ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const TextSpan(text: '고객 Pool을 늘리기 위한 동기부여도 가능토록 하였습니다.\n\n'),
            const TextSpan(
              text:
                  '가망고객 화면과, 계약자의 경우 계약내용까지 등록 및 관리할수 있도록 계약자화면,'
                  ' 생일, 상령일, 미관리 고객, 게약내용 등을 검색하여 조회할 수 있는 '
                  '검색화면을 구성하여 체계적인 관리가 가능하도록 하였으며, 모든 일자는 변경이 가능합니다.\n\n',
            ),
            const TextSpan(
              text:
                  'Dashboard 화면에서는 현재 관리중인 가망고객이나 계약자의 통계를 확인할 수 있도록 하여,'
                  ' 전체적인 관리가 가능할수 있도록 화면을 구성해 놓았습니다.\n\n',
            ),

            const TextSpan(text: '무료회원은 '),
            TextSpan(
              text: '$freeCount명',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const TextSpan(
              text:
                  ' 까지 등록하여 사용이 가능하며, 유료회원은 고객수 제한 없이 고객을'
                  ' 등록하여 사용할 수 있습니다. (문의는 아래 메일 참고)\n\n',
            ),
            const TextSpan(
              text:
                  '유료회원의 경우에는 등록되어 있는 고객의 정보를 등록된 E-mail을 통해 Excel로 받을 수도 있습니다.\n\n\n',
            ),

            TextSpan(
              text: '문의: $adminEmail',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
