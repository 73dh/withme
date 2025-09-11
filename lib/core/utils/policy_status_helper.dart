import 'package:flutter/material.dart';
import '../../domain/model/policy_model.dart';
import '../domain/enum/policy_state.dart';

class PolicyStatusHelper {
  /// 계약 상태가 취소 또는 만기인지
  static bool isNotKeepPolicy(PolicyModel policy) {
    return policy.policyState == PolicyStatus.cancelled.label ||
        policy.policyState == PolicyStatus.lapsed.label;
  }

  /// 보험료 텍스트 스타일
  static TextStyle premiumTextStyle(
      PolicyModel policy, TextTheme textTheme, ColorScheme colorScheme) {
    final notKeep = isNotKeepPolicy(policy);
    return notKeep
        ? textTheme.labelLarge!.copyWith(
      color: colorScheme.error,
      decoration: TextDecoration.lineThrough,
    )
        : textTheme.labelLarge!.copyWith(color: colorScheme.onSurface);
  }

  /// 상태 배경 색상
  static Color statusBackgroundColor(
      PolicyModel policy, ColorScheme colorScheme) {
    final notKeep = isNotKeepPolicy(policy);
    return notKeep
        ? colorScheme.errorContainer.withValues(alpha: 0.3)
        : colorScheme.tertiaryContainer.withValues(alpha: 0.2);
  }

  /// 상태 텍스트 색상
  static Color statusTextColor(PolicyModel policy, ColorScheme colorScheme) {
    final notKeep = isNotKeepPolicy(policy);
    return notKeep ? colorScheme.error : colorScheme.onTertiaryContainer;
  }

  /// 상태 기본 색상 (아이콘/라인 등)
  static Color statusColor(PolicyModel policy, ColorScheme colorScheme) {
    final notKeep = isNotKeepPolicy(policy);
    return notKeep ? colorScheme.error : colorScheme.primary;
  }
}
